extends Node

var lobby_id = 0
var peer = SteamMultiplayerPeer.new()
var client = null
var connect_ip = "127.0.0.1"
var default_PORT = 55455
var unique_id = -1
var game : MP_Map = null

var gameInteractables = null

var playerListNode = {}

func _ready():
	peer.lobby_created.connect(on_lobby_created)
	multiplayer.peer_connected.connect(client_connected_to_server)
	#multiplayer.peer_disconnected.connect(player_left)
	

func host_server():
	peer.create_lobby(SteamMultiplayerPeer.LOBBY_TYPE_PUBLIC, 4)
	multiplayer.multiplayer_peer = peer
	
	#unique_id = server.get_unique_id()

func on_lobby_created(connect, id):
	if connect:
		lobby_id = id
		Steam.setLobbyData(lobby_id, "name", str(Steam.getPersonaName() + "'s Lobby"))
		Steam.setLobbyJoinable(lobby_id, true)
		Steam.setLobbyMemberData(lobby_id, "user", str(Steam.getSteamID()) )
		print("Player has started a server with id: ", multiplayer.get_unique_id())

func join_server(id):
	peer.connect_lobby(id)
	multiplayer.multiplayer_peer = peer
	lobby_id = id
	
	
func client_connected_to_server(id):
	#Notificar al host que se acaba de unir un nuevo jugador
	get_tree().change_scene_to_file("res://Scenes/Levels/initial_level.tscn")
	if multiplayer.get_unique_id() == 1:
		print("A new client has joined with id :" , id)
		return
	
	#Notificar al cliente que se acaba de unir
	print("Client has connected to server with id: ", multiplayer.get_unique_id())
	
	
func player_joined(id):
	#if its the host -> ignore
	if id == 1:
		return

	for index in game.players_node.get_child_count():
		var player : Player = game.players_node.get_child(index)
		var dict_data = game.players["player"+player.name]
		game.set_player_data.rpc_id(id, player.name.to_int(), player.name)
		game.request_game_info.rpc_id(id, dict_data)
	game.init_player(id)
	game.set_player_data.rpc(id, id)
	
	
	update_client_Data.rpc()
	show_all_players.rpc_id(id)
	
func player_left(_id):
	for p in game.players_node.get_children():
		if p.name == str(_id):
			p.queue_free()
	
	game.players.erase("player" + str(_id))

func load_map():
	pass

@rpc("call_remote", "any_peer")
func update_client_Data():
	var PauseScene = load("res://Scenes/UI/Pause_Menu/pause_menu.tscn")
	var weaponSelectionScene = load("res://Scenes/UI/Team_Selection/Team_selection.tscn")
	
	for player in game.players_node.get_children():
		if player.name == str(multiplayer.get_unique_id()):
			continue
		var node : Node3D = Node3D.new() 
		node.name = player.name
		game.add_child(node)
		
		var pauseMenu : Pause_Menu = PauseScene.instantiate()
		pauseMenu.name = str(player.name.to_int())
		pauseMenu.set_multiplayer_authority(player.name.to_int())
		node.add_child(pauseMenu)
		player.pauseMenu = pauseMenu
		
		var weaponSelection : WeaponSelection_Menu = weaponSelectionScene.instantiate()
		weaponSelection.name = str(player.name.to_int())
		weaponSelection.player = player
		weaponSelection.set_multiplayer_authority(player.name.to_int())
		node.add_child(weaponSelection)
		player.weaponSelectionMenu = weaponSelection
	
@rpc("any_peer", "call_local", "reliable")
func update_teams(identifier, newTeam):
	for player in game.players_node.get_children():
		if str(identifier) == player.name:
			player.team = newTeam

@rpc("any_peer", "call_local", "reliable")
func updatePlayerWeapon(identifier, weaponScenePath : String):
	var weapon : PackedScene = load(weaponScenePath)
	var weaponSpawned : Weapon = weapon.instantiate()
	for player : Player in game.players_node.get_children():
		if str(identifier) == player.name:
			weaponSpawned.set_multiplayer_authority(player.name.to_int())
			
			weaponSpawned.position = weaponSpawned.weaponData.weaponSpawnPosition
			weaponSpawned.handsNode = player.arms.get_path()
			
			if player.arms.weaponHolder.get_child_count() > 0:
				player.arms.weaponHolder.remove_child(player.arms.weaponHolder.get_child(0))
			player.arms.weaponHolder.add_child(weaponSpawned) 
			player.arms.actualWeapon = player.arms.weaponHolder.get_child(0)
			player.eyes.get_child(0).setRecoil(player.arms.actualWeapon.weaponData.recoil)
			player.arms.state_machine.transition_to("SwappingWeapon")
			player.visible = true
			player.weaponSelectionMenu.visible = false
			var dict_data : Dictionary = {"id": identifier ,"weaponName" : weaponSpawned.weaponData.name, "weaponScenePath": weaponScenePath}
			game.players["player" + str(identifier)] = dict_data

@rpc("any_peer", "call_local")
func show_all_players():
	for player : Player in game.players_node.get_children():
		if player.arms.weaponHolder.get_child_count() > 0:
			player.visible = true

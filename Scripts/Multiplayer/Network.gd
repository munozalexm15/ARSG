extends Node

var lobby_id = 0
var peer : SteamMultiplayerPeer = null
var game : MP_Map = null

var gameData : Dictionary = {}

func _ready():
	peer = SteamMultiplayerPeer.new()
	OS.set_environment("SteamAppID", str(480))
	OS.set_environment("SteamGameID", str(480))
	Steam.steamInitEx()
	
	#si se crea un lobby
	peer.lobby_created.connect(on_lobby_created)
	
	#si se mete un cliente
	multiplayer.peer_connected.connect(client_connected_to_server)
	
	multiplayer.server_disconnected.connect(
		func(): get_tree().change_scene_to_file("res://Scenes/Menu/main_menu.tscn"))

func _process(_delta):
	Steam.run_callbacks()
	
func host_server(roomData : Dictionary):
	gameData = roomData
	peer.create_lobby(roomData["lobbyType"], roomData["playerQuantity"])
	multiplayer.multiplayer_peer = peer
	
	#si el server cierra
	multiplayer.server_disconnected.connect(
		func():
		get_tree().change_scene_to_file("res://Scenes/Menu/main_menu.tscn"))
	#unique_id = server.get_unique_id()

func on_lobby_created(connection, id):
	if connection:
		lobby_id = id
		Steam.setLobbyData(lobby_id, "name", gameData["lobbyName"])
		Steam.setLobbyData(lobby_id, "gamemode", gameData["gameMode"])
		Steam.setLobbyData(lobby_id, "map", gameData["mapName"])
		Steam.setLobbyData(lobby_id, "mapPath", gameData["mapPath"])
		Steam.setLobbyData(lobby_id, "goal", str(gameData["goal"]) )
		Steam.setLobbyData(lobby_id, "time", str(gameData["time"]) )
		Steam.setLobbyJoinable(lobby_id, true)
		print("Player has started a server with id: ", multiplayer.get_unique_id())
		get_tree().change_scene_to_file(gameData["mapPath"])

func join_server(id):
	var map = Steam.getLobbyData(id, "mapPath")
	get_tree().change_scene_to_file(map)
	peer.connect_lobby(id)
	multiplayer.multiplayer_peer = peer
	lobby_id = id
	
func client_connected_to_server(id):
	#Notificar al host que se acaba de unir un nuevo jugador, y enviarle al cliente todos los datos de los jugadores y la partida (armas, muertes, bajas, etc.)
	if multiplayer.get_unique_id() == 1:
		print("A new client has joined with id :" , id)
		player_joined.rpc_id(id, id, game.players, game.matchTimer.time_left, game.team1GoalProgress, game.team2GoalProgress, gameData)
		return
	
	#Notificar al cliente que se acaba de unir
	print("Client has connected to server with id: ", multiplayer.get_unique_id())
	
@rpc("any_peer", "call_remote")
func player_joined(id, players_dict, time_left, team1Progress, team2Progress, hostGameData):
	#if its the host -> ignore
	if id == 1:
		return
	
	gameData = hostGameData
	game.matchGoal = int(Steam.getLobbyData(lobby_id, "goal"))
	game.matchTime = int(Steam.getLobbyData(lobby_id, "time"))
	game.matchTimer.wait_time = time_left
	game.matchTimer.start()
	game.team1GoalProgress = team1Progress
	game.team2GoalProgress = team2Progress
	
	game.players = players_dict
	#for each player, get its data and set its respective nodes / configuration
	for index in game.players_node.get_child_count():
		var player : Player = game.players_node.get_child(index)
		var player_data = players_dict["player"+player.name]
		game.set_player_data.rpc_id(multiplayer.get_unique_id(), player.name.to_int(), player.name)
		game.request_game_info.rpc_id(multiplayer.get_unique_id(), player_data)
	
	game.init_player.rpc(multiplayer.get_unique_id())
	await game.player_spawner.spawned
	game.set_player_data.rpc(multiplayer.get_unique_id(), id)
	show_all_players.rpc_id(multiplayer.get_unique_id())

@rpc("any_peer", "call_local", "reliable")
func player_left(_id):
	for p in game.players_node.get_children():
		if p.name == str(_id):
			p.queue_free()
	
	game.players.erase("player" + str(_id))
	gameData.erase("player" + str(_id))
	
	Steam.leaveLobby(lobby_id)
	for x in Steam.getNumLobbyMembers(lobby_id):
		var member_steam_id = Steam.getLobbyMemberByIndex(lobby_id, x)
		Steam.closeP2PSessionWithUser(member_steam_id)
	

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
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED  
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
			var playerDict = game.players["player" + str(identifier)]
			playerDict["weaponName"] = weaponSpawned.weaponData.name
			playerDict["weaponScenePath"] = weaponScenePath

@rpc("any_peer", "call_local")
func show_all_players():
	for player : Player in game.players_node.get_children():
		if player.arms.weaponHolder.get_child_count() > 0:
			player.visible = true

func endGame():
	for x in Steam.getNumLobbyMembers(lobby_id):
		var member_steam_id = Steam.getLobbyMemberByIndex(lobby_id, x)
		var member_peer_id = peer.get_peer_id_from_steam64(member_steam_id)
		
	gameData.clear()
	for player in game.players_node.get_children():
		call_deferred("queue_free")
	
	call_deferred("load_main_menu")

func load_main_menu():
	if multiplayer.get_unique_id() == 1:
		peer.close()
		
	get_tree().change_scene_to_file("res://Scenes/Menu/main_menu.tscn")
	

@rpc("reliable", "any_peer", "call_local")
func kicked():
	peer.disconnect_peer(multiplayer.get_unique_id())

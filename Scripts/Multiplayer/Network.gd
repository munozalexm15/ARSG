extends Node

var server = null
var client = null
var connect_ip = "127.0.0.1"
var default_PORT = 55455
var unique_id = -1
var players = 0

var game : MP_Map = null

var gameInteractables = null

var playerListNode = {}

func _ready():
	multiplayer.peer_connected.connect(player_joined)
	multiplayer.peer_disconnected.connect(player_left)

func host_server():
	server = ENetMultiplayerPeer.new()
	server.create_server(default_PORT)
	multiplayer.multiplayer_peer = server
	unique_id = server.get_unique_id()
	players+=1
	
func join_server():
	client = ENetMultiplayerPeer.new()
	client.create_client(connect_ip, default_PORT)
	multiplayer.multiplayer_peer = client
	unique_id = client.get_unique_id()

func player_joined(id):
	#if its the host -> ignore
	if id == 1:
		return
	
	
	game.init_player(id)
	game.set_player_data.rpc(id, id)
	update_client_Data.rpc()
	

@rpc("any_peer", "call_local")
func player_left(_id):
	for p in game.players_node.get_children():
		if p.name == str(_id):
			p.queue_free()

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

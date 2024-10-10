class_name MP_Map
extends Node3D

const PORT = 9999
var peer : SteamMultiplayerPeer = SteamMultiplayerPeer.new()
var players : Array = []
var death_count = 0

@export var PlayerScene = preload("res://Scenes/Characters/Main_character.tscn")
@export var PauseScene = preload("res://Scenes/UI/Pause_Menu/pause_menu.tscn")
@export var weaponSelectionScene = preload("res://Scenes/UI/Team_Selection/Team_selection.tscn")

@export var team1SkinsResources : Array
@export var team2SkinsResources : Array


@onready var players_node = $FadeShader/SubViewport/DitheringShader/SubViewport
@onready var player_spawner : MultiplayerSpawner = $MultiplayerSpawner
@onready var bullets_node : Node3D= $BulletsParent

@onready var interactables_node : Node3D = $InteractablesParent
@onready var spawnPoints_node : Node3D= $SpawnPoints

@onready var dashboardMatch : Control = $DashboardMatch

@onready var matchTimer : Timer = $MatchTimer

@onready var killFeedVBox = $KillFeed/KillFeedHistory
@onready var ChatMessagesDisplay : VBoxContainer = $ChatDisplay/VBoxContainer2/VBoxContainer
@onready var chatText : TextEdit = $ChatDisplay/VBoxContainer2/ChatText

var matchGoal = 0
var team1GoalProgress = 0
var team2GoalProgress = 0
var matchTime = 0
var matchTimeLeft = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	Network.game = self
	if multiplayer.get_unique_id() == 1:
		matchGoal = Network.gameData["goal"]
		matchTime = Network.gameData["time"]
		matchTimer.wait_time = matchTime
		matchTimer.start()
		init_player.rpc(multiplayer.get_unique_id())
		set_player_data.rpc(multiplayer.get_unique_id(), multiplayer.get_unique_id())
		Steam.setLobbyJoinable(Network.lobby_id, true)
	else:
		await get_tree().create_timer(2).timeout
		Network.client_connected_to_server.rpc_id(1, multiplayer.get_unique_id())
	

func _process(_delta):
	pass

func  _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("Open Chat") and not chatText.has_focus():
		chatText.grab_focus()
		chatText.accept_event()
	
	if Input.is_action_just_pressed("Send Message") and chatText.has_focus():
		chatText.release_focus()
		chatText.text.replace("\n", "")
		if chatText.text.length() == 0:
			return
			
		Network._on_send_chat_pressed(Steam.getFriendPersonaName(Steam.getSteamID()) + " : " + chatText.text)
		chatText.text = ""
	
	if (matchGoal == team1GoalProgress or matchGoal == team2GoalProgress) or matchTimer.time_left == 0:
		return
	if Input.is_action_pressed("Scoreboard"):
		dashboardMatch.visible = true
	if Input.is_action_just_released("Scoreboard"):
		dashboardMatch.visible = false


@rpc("any_peer", "call_local", "reliable")
func init_player(peer_id):
	var player : Player = PlayerScene.instantiate()
	player.name = str(peer_id)
	if multiplayer.get_unique_id() == 1:
		players_node.add_child(player)
	player.set_multiplayer_authority(peer_id)
	
	var dict_data : Dictionary = {"id": str(peer_id) ,"name": Steam.getPersonaName(), "score" : 0, "kills": 0, "assists" : 0, "deaths": 0}
	players.append(dict_data)
	
	if Network.gameData["gameMode"] == "FACE OFF":
		var team : int = randi_range(0, 1)
		var skin : PlayerSkin = null
		if team == 1:
			skin = team1SkinsResources.pick_random()
		else:
			skin = team2SkinsResources.pick_random()
		
		player.arms.handsAssignedTexture = skin.rightHandSkin
		
		player.player_body.playerMesh.get_active_material(0).set_shader_parameter("albedo", skin.BodySkin)
		player.player_body.playerMesh.get_active_material(1).set_shader_parameter("albedo", skin.HeadSkin)
		
	await get_tree().process_frame
	dashboardMatch.get_lobby_data()

##Creating and assigning a team selection, class selection and pause menus to a player
@rpc("any_peer", "call_local", "reliable")
func set_player_data(peer_id, playerName):
	var node : Node3D = Node3D.new()
	node.name = str(playerName)
	add_child(node)
	
	var player : Player = null
	for p in players_node.get_children():
		if p.name == str(playerName):
			player = p
	
	print(multiplayer.get_unique_id(), " con referencia al player: " , player.name)
	
	player.visible = false
	player.global_position = random_spawn()
	
	var pauseMenu : Pause_Menu = PauseScene.instantiate()
	pauseMenu.name = str(peer_id) + "pauseMenu"
	pauseMenu.set_multiplayer_authority(peer_id) 
	node.add_child(pauseMenu)
	player.pauseMenu = pauseMenu
	pauseMenu.player = player
	
	var weaponSelection : WeaponSelection_Menu = weaponSelectionScene.instantiate()
	weaponSelection.name = str(peer_id) + "weaponMenu"
	weaponSelection.player = player
	weaponSelection.set_multiplayer_authority(peer_id)
	node.add_child(weaponSelection)
	player.weaponSelectionMenu = weaponSelection

func replace_weapon_content(weapon : Node3D):
	for child : Node in weapon.get_children():
		child.queue_free()

func random_spawn():
	var randomValue = randi_range(0, spawnPoints_node.get_child_count() -1)
	var spawnPoint = spawnPoints_node.get_child(randomValue)
	return spawnPoint.position

#load client data from the other players already in the match.
@rpc("any_peer", "call_local", "reliable")
func request_game_info(player_dict : Dictionary):
	for index in players_node.get_child_count():
		var player : Player = players_node.get_child(index)
		if player.name == player_dict["id"]:
			if player_dict.has("primaryWeaponPath"):
				var weaponScene : PackedScene = load(player_dict["primaryWeaponPath"])
				var weapon : Weapon = weaponScene.instantiate()
				weapon.handsNode = player.arms.get_path()
				player.arms.weaponHolder.add_child(weapon)
				
			if player_dict.has("secondaryWeaponPath"):
				var weaponScene : PackedScene = load(player_dict["secondaryWeaponPath"])
				var weapon : Weapon = weaponScene.instantiate()
				weapon.handsNode = player.arms.get_path()
				player.arms.weaponHolder.add_child(weapon)
			
			for weapon : Weapon in player.arms.weaponHolder.get_children():
				if weapon.weaponData.name == player_dict["actualWeaponName"]:
					player.arms.actualWeapon = weapon

func _on_match_timer_timeout():
	if multiplayer.get_unique_id() == 1:
		Network.endGame.rpc(str("THE WINNER IS " , players[0]["name"]) ) 
		await get_tree().create_timer(5).timeout
		if multiplayer.get_unique_id() == 1:
			Network.close_match()
			get_tree().change_scene_to_file("res://Scenes/Menu/main_menu.tscn")

func add_kill_to_killFeed(killer_name : String, weaponImage : CompressedTexture2D, dead_name : String):
	var playerRow : HBoxContainer = HBoxContainer.new()
	killFeedVBox.add_child(playerRow)
	
	var killerPlayerName : Label = Label.new()
	killerPlayerName.text = killer_name
	playerRow.add_child(killerPlayerName)
	
	var weaponKillerImage : TextureRect = TextureRect.new()
	weaponKillerImage.texture = weaponImage
	weaponKillerImage.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	playerRow.add_child(weaponKillerImage)
	
	var deadPlayerName : Label = Label.new()
	deadPlayerName.text = dead_name
	playerRow.add_child(deadPlayerName)
	
	await get_tree().create_timer(4).timeout
	playerRow.queue_free()

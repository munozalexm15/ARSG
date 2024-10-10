class_name MP_Map
extends Node3D

var players : Array = []
var death_count = 0

@export var PlayerScene = preload("res://Scenes/Characters/Main_character.tscn")
@export var PauseScene = preload("res://Scenes/UI/Pause_Menu/pause_menu.tscn")
@export var weaponSelectionScene = preload("res://Scenes/UI/Team_Selection/Team_selection.tscn")

@export var team1SkinsResources : Array
@export var team2SkinsResources : Array


@onready var players_node = $FadeShader/SubViewport/DitheringShader/SubViewport
@onready var menus_node = $PauseMenusNode
@onready var weaponSelections_node = $weaponSelectionNode
@onready var bullets_node : Node3D= $BulletsParent

@onready var interactables_node : Node3D = $InteractablesParent
@onready var spawnPoints_node : Node3D= $SpawnPoints

@onready var dashboardMatch : Control = $DashboardMatch

@onready var matchTimer : Timer = $MatchTimer

@onready var killFeedVBox = $KillFeed/KillFeedHistory
@onready var ChatMessagesDisplay : VBoxContainer = $ChatDisplay/VBoxContainer2/VBoxContainer
@onready var chatText : TextEdit = $ChatDisplay/VBoxContainer2/ChatText

@onready var pauseMenuSpawner : MultiplayerSpawner = $pauseMenuSpawner
@onready var playerSpawner : MultiplayerSpawner = $PlayerSpawner
@onready var weaponSelectionSpawner : MultiplayerSpawner = $weaponSelectionSpawner

var matchGoal = 0
var team1GoalProgress = 0
var team2GoalProgress = 0
var matchTime = 0
var matchTimeLeft = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	weaponSelectionSpawner.spawn_function = Callable(self, "set_player_weaponSelection")
	pauseMenuSpawner.spawn_function = Callable(self, "set_player_pause_menu")
	playerSpawner.spawn_function = Callable(self, "init_player")
	
	Network.game = self
	#multiplayer.connected_to_server.connect(loadGame)
	
	if Network.role == "Host":
		generatePlayer(multiplayer.get_unique_id())
		matchGoal = Network.gameData["goal"]
		matchTime = Network.gameData["time"]
		matchTimer.wait_time = matchTime
		#matchTimer.start()
		
		#dashboardMatch.get_lobby_data()
		#uiSpawner.spawn_function = Callable(self, "set_player_data")
		#uiSpawner.spawn()
		#init_player.rpc(multiplayer.get_unique_id())
		#set_player_data.rpc(multiplayer.get_unique_id(), multiplayer.get_unique_id())
		Steam.setLobbyJoinable(Network.lobby_id, true)
	
func generatePlayer(id):
	var weaponSelectionInstance = weaponSelectionSpawner.spawn(id)
	var pauseMenuInstance = pauseMenuSpawner.spawn(id)
	var playerInstance = playerSpawner.spawn(id)
	
	playerInstance.global_position = random_spawn()
	
	playerInstance.pauseMenu = pauseMenuInstance
	pauseMenuInstance.player = playerInstance
	playerInstance.weaponSelectionMenu = weaponSelectionInstance
	weaponSelectionInstance.player = playerInstance
	
	
	setAuthToPlayer.rpc(playerInstance.name, pauseMenuInstance.name, weaponSelectionInstance.name, id)
	
	if Network.gameData["gameMode"] == "FACE OFF":
		#var team : int = randi_range(0, 1)
		var skin : PlayerSkin = null
		if players.size() == 1:
			skin = team1SkinsResources.pick_random()
		else:
			skin = team2SkinsResources.pick_random()
		
		playerInstance.arms.handsAssignedTexture = skin.rightHandSkin
		
		playerInstance.player_body.playerMesh.get_active_material(0).set_shader_parameter("albedo", skin.BodySkin)
		playerInstance.player_body.playerMesh.get_active_material(1).set_shader_parameter("albedo", skin.HeadSkin)

@rpc("any_peer", "call_local")
func setAuthToPlayer(playernode_Name, pauseMenuNode_Name, weaponSelectionNode_Name, newId):
	var playerInstance = players_node.get_node("./" + playernode_Name)
	var menuInstance = menus_node.get_node("./" + pauseMenuNode_Name)
	var selectionInstance = weaponSelections_node.get_node("./" + weaponSelectionNode_Name)
	
	playerInstance.set_multiplayer_authority(newId, true)
	menuInstance.set_multiplayer_authority(newId, true)
	selectionInstance.set_multiplayer_authority(newId, true)
	
	playerInstance.global_position = random_spawn()
	
	playerInstance.pauseMenu = menuInstance
	menuInstance.player = playerInstance
	playerInstance.weaponSelectionMenu = selectionInstance
	selectionInstance.player = playerInstance
	
func loadGame():
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
	player.set_multiplayer_authority(peer_id)
	player.name = str(peer_id)
	#player.set_multiplayer_authority(peer_id)
	var dict_data : Dictionary = {"id": str(peer_id) ,"name": Steam.getPersonaName(), "score" : 0, "kills": 0, "assists" : 0, "deaths": 0}
	players.append(dict_data)
	return player

func set_player_pause_menu(peer_id):
	var pauseMenu : Pause_Menu = PauseScene.instantiate()
	pauseMenu.name = str(peer_id) + "pauseMenu"
	pauseMenu.set_multiplayer_authority(peer_id)
	return pauseMenu

func set_player_weaponSelection(peer_id):
	var weaponSelection : WeaponSelection_Menu = weaponSelectionScene.instantiate()
	weaponSelection.name = str(peer_id) + "weaponSelection"
	weaponSelection.set_multiplayer_authority(peer_id)
	return weaponSelection

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
	
	#print(multiplayer.get_unique_id(), " con referencia al player:" , player.name)
	
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
	
	#skin assignation
	if Network.gameData["gameMode"] == "FACE OFF":
		#var team : int = randi_range(0, 1)
		var skin : PlayerSkin = null
		if players.size() == 1:
			skin = team1SkinsResources.pick_random()
		else:
			skin = team2SkinsResources.pick_random()
		
		player.arms.handsAssignedTexture = skin.rightHandSkin
		
		player.player_body.playerMesh.get_active_material(0).set_shader_parameter("albedo", skin.BodySkin)
		player.player_body.playerMesh.get_active_material(1).set_shader_parameter("albedo", skin.HeadSkin)

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

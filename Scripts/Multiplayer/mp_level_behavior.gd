class_name MP_Map
extends Node3D

const PORT = 9999
var peer : SteamMultiplayerPeer = SteamMultiplayerPeer.new()
var players : Dictionary = {}

signal isMapLoaded

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

@onready var dashboardMatch : PanelContainer = $DashboardMatch

@onready var matchTimer : Timer = $MatchTimer

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

func _process(_delta):
	if Input.is_action_pressed("Dashboard"):
		dashboardMatch.visible = true
	if Input.is_action_just_released("Dashboard"):
		dashboardMatch.visible = false

@rpc("any_peer", "call_local", "reliable")
func init_player(peer_id):
	var player : Player = PlayerScene.instantiate()
	player.name = str(peer_id)
	if multiplayer.get_unique_id() == 1:
		players_node.add_child(player)
	player.set_multiplayer_authority(peer_id)
	var dict_data : Dictionary = {"id": str(peer_id) ,"name": Steam.getPersonaName(), "score" : 0, "kills": 0, "assists" : 0, "deaths": 0}
	players["player" + str(peer_id)] = dict_data
		
	dashboardMatch.get_lobby_data.rpc()

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
	
	player.visible = false
	player.global_position = random_spawn()
	
	var pauseMenu : Pause_Menu = PauseScene.instantiate()
	pauseMenu.name = str(peer_id) + "pauseMenu"
	pauseMenu.set_multiplayer_authority(peer_id) 
	node.add_child(pauseMenu)
	player.pauseMenu = pauseMenu
	
	var weaponSelection : WeaponSelection_Menu = weaponSelectionScene.instantiate()
	weaponSelection.name = str(peer_id) + "weaponMenu"
	weaponSelection.player = player
	weaponSelection.set_multiplayer_authority(peer_id)
	node.add_child(weaponSelection)
	player.weaponSelectionMenu = weaponSelection
	
	#skin assignation
	if Network.gameData["gameMode"] == "FREE FOR ALL":
		var team : int = randi_range(0, 1)
		var skin : PlayerSkin = null
		if team == 0:
			skin = team1SkinsResources.pick_random()
		else:
			skin = team2SkinsResources.pick_random()
		
		
		player.arms.handsAssignedTexture = skin.rightHandSkin
		
		player.player_body.playerMesh.get_active_material(0).set_shader_parameter("albedo", skin.BodySkin)
		player.player_body.playerMesh.get_active_material(1).set_shader_parameter("albedo", skin.BodySkin)

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
			if player_dict.has("weaponScenePath"):
				var weaponScene : PackedScene = load(player_dict["weaponScenePath"])
				var weapon : Weapon = weaponScene.instantiate()
				weapon.handsNode = player.arms.get_path()
				player.arms.weaponHolder.add_child(weapon)
				player.arms.actualWeapon = player.arms.weaponHolder.get_child(0)

func _on_match_timer_timeout():
	pass

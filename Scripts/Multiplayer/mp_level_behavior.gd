class_name MP_Map
extends Node3D

const PORT = 9999
var enet_peer = ENetMultiplayerPeer.new()


@export var PlayerScene = preload("res://Scenes/Characters/Main_character.tscn")
@export var PauseScene = preload("res://Scenes/UI/Pause_Menu/pause_menu.tscn")

@onready var players_node = $FadeShader/SubViewport/DitheringShader/SubViewport
@onready var bullets_node : Node3D= $BulletsParent

@onready var interactables_node : Node3D = $InteractablesParent
@onready var spawnPoints_node : Node3D= $SpawnPoints

# Called when the node enters the scene tree for the first time.
func _ready():
	if multiplayer.get_unique_id() == 1:
		init_player.rpc(multiplayer.get_unique_id())
		set_player_data.rpc(multiplayer.get_unique_id(), multiplayer.get_unique_id())
	
	Network.game = self

func start_game():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

@rpc("authority", "call_local", "reliable")
func init_player(peer_id):
	var player : Player = PlayerScene.instantiate()
	player.name = str(peer_id)
	players_node.add_child(player)
	
	player.set_multiplayer_authority(peer_id)

@rpc("any_peer", "call_local", "reliable")
func set_player_data(peer_id, playerName):
	var player : Player = null
	for p in players_node.get_children():
		if p.name == str(playerName):
			player = p
	
	player.global_position = random_spawn()
	
	var pauseMenu = PauseScene.instantiate()
	pauseMenu.name = str(peer_id)
	pauseMenu.set_multiplayer_authority(peer_id)
	add_child(pauseMenu)
	player.pauseMenu = pauseMenu

func replace_weapon_content(weapon : Node3D):
	for child : Node in weapon.get_children():
		child.queue_free()


func random_spawn():
	var randomValue = randi_range(0, spawnPoints_node.get_child_count() -1)
	var spawnPoint = spawnPoints_node.get_child(randomValue)
	return spawnPoint.position

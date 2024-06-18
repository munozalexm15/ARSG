extends Node3D

const PORT = 9999
var enet_peer = ENetMultiplayerPeer.new()


@export var PlayerScene = preload("res://Scenes/Characters/Main_character.tscn")
@export var PauseScene = preload("res://Scenes/UI/Pause_Menu/pause_menu.tscn")

@onready var players_node = $FadeShader/SubViewport/DitheringShader/SubViewport
# Called when the node enters the scene tree for the first time.
func _ready():
	Lobby.player_loaded.rpc_id(1) # Tell the server that this peer has loaded.

func start_game():
	init_player.rpc(1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

@rpc("call_local", "reliable")
func init_player(peer_id):
	
	var playerMenu : Pause_Menu = PauseScene.instantiate()
	add_child(playerMenu)
	
	var player : Player = PlayerScene.instantiate()
	player.name = str(1)
	players_node.add_child(player)
	player.pauseMenu = playerMenu
	
	

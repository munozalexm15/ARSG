extends Node3D

const PORT = 9999
var enet_peer = ENetMultiplayerPeer.new()


@export var PlayerScene = preload("res://Scenes/Characters/Main_character.tscn")
@export var PauseScene = preload("res://Scenes/UI/Pause_Menu/pause_menu.tscn")

@onready var players_node = $FadeShader/SubViewport/DitheringShader/SubViewport
# Called when the node enters the scene tree for the first time.
func _ready():
	Lobby.player_loaded.rpc_id(multiplayer.get_unique_id()) # Tell the server that this peer has loaded.

func start_game():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func init_player(peer_id):
	
	var playerMenu : Pause_Menu = PauseScene.instantiate()
	add_child(playerMenu)
	
	var player : Player = PlayerScene.instantiate()
	player.name = str(peer_id)
	players_node.add_child(player)
	player.pauseMenu = playerMenu
	
	

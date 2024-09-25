extends Control

@export var loadingShader : ShaderMaterial

var loadedScene = null

@onready var loadStatus = $LOAD_status

# Called when the node enters the scene tree for the first time.
func _ready():
	loadingShader.set_shader_parameter("percentage", 0)
	ResourceLoader.load_threaded_request(LoadScreenHandler.next_scene)
	Steam.steamInitEx()
	multiplayer.peer_connected.connect(join_room)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var progress = []
	ResourceLoader.load_threaded_get_status(LoadScreenHandler.next_scene, progress)
	loadingShader.set_shader_parameter("percentage", progress[0])
	
	if progress[0] == 1:
		var packed_scene = ResourceLoader.load_threaded_get(LoadScreenHandler.next_scene)
		if Network.peer.get_class() != "OfflineMultiplayerPeer":
			start_map(packed_scene)
		else:
			loadingShader.set_shader_parameter("percentage", 100)
			loadedScene = packed_scene
			Network.join_server(Network.lobby_id)
			loadStatus.text = "JOINING ROOM..."


func start_map(packed_scene : PackedScene):
	#host joining
	get_tree().change_scene_to_packed(packed_scene)

func join_room(_id):
	if Network.peer.get_connection_status() == 2:
		get_tree().change_scene_to_packed(loadedScene)
	else:
		get_tree().change_scene_to_file("res://Scenes/Menu/main_menu.tscn")

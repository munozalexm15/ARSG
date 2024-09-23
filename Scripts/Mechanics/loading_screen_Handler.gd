extends Control

@export var loadingShader : ShaderMaterial

# Called when the node enters the scene tree for the first time.
func _ready():
	loadingShader.set_shader_parameter("percentage", 0)
	ResourceLoader.load_threaded_request(LoadScreenHandler.next_scene)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var progress = []
	ResourceLoader.load_threaded_get_status(LoadScreenHandler.next_scene, progress)
	loadingShader.set_shader_parameter("percentage", progress[0])
	
	if progress[0] == 1:
		var packed_scene = ResourceLoader.load_threaded_get(LoadScreenHandler.next_scene)
		join_or_host_match(packed_scene)
		

func join_or_host_match(packed_scene : PackedScene):
	if Network.peer.get_class() == "OfflineMultiplayerPeer":
		Network.join_server(Network.lobby_id)
		await multiplayer.peer_connected
		loadingShader.set_shader_parameter("percentage", 0)
		get_tree().change_scene_to_packed(packed_scene)
	else:
		get_tree().change_scene_to_packed(packed_scene)

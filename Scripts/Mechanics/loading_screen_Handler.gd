extends Control

@export var loadingShader : ShaderMaterial

# Called when the node enters the scene tree for the first time.
func _ready():
	loadingShader.set_shader_parameter("percentage", 0)
	ResourceLoader.load_threaded_request(LoadScreenHandler.next_scene)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var progress = []
	ResourceLoader.load_threaded_get_status(LoadScreenHandler.next_scene, progress)
	loadingShader.set_shader_parameter("percentage", progress[0])
	
	if progress[0] == 1:
		var packed_scene = ResourceLoader.load_threaded_get(LoadScreenHandler.next_scene)
		loadingShader.set_shader_parameter("percentage", 0)
		print("mapa cargado")
		if multiplayer.is_server():
			Lobby.load_game.rpc(packed_scene)
		else:
			Lobby.load_game(packed_scene)

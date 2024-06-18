extends Node

@onready var ditheringShader = preload("res://GameResources/Materials/Dithering_Shader_Material.tres") 

var configData : ConfigFile

# Called when the node enters the scene tree for the first time.
func _ready():
	configData = ConfigFile.new()
	var loadedData = configData.load("res://GameSettings.cfg")
	if loadedData == OK:
		loadGameSettings()
	
	if loadedData != OK:
		var configData = ConfigFile.new()
		configData.set_value("Video", "Resolution", Vector2i(1920, 1080))
		configData.set_value("Video", "isFullscreen", true)
		configData.set_value("Video", "hasDithering", true)
		configData.set_value("Video", "V-Sync", true)
		configData.set_value("Video", "ColorDepth", 5)
		configData.set_value("Video", "ResolutionScale", 2)
		configData.set_value("Audio", "Weapons", 1)
		configData.set_value("Audio", "WeaponSliderValue", 1)
		configData.set_value("Audio", "Environment", 1)
		configData.set_value("Audio", "EnvironmentSliderValue", 1)
		configData.set_value("Audio", "Effects", 1)
		configData.set_value("Audio", "EffectsSliderValue", 1)
		configData.save("res://GameSettings.cfg")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func loadGameSettings():
	if configData.get_value("Video", "isFullscreen", true) == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	get_window().size = configData.get_value("Video", "Resolution", Vector2i(1024, 768))
	
	if configData.get_value("Video", "hasDithering", true) == true:
		ditheringShader.set_shader_parameter("dithering", true)
	else:
		ditheringShader.set_shader_parameter("dithering", false)
	
	if configData.get_value("Video", "V-Sync", true) == true:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	
	ditheringShader.set_shader_parameter("color_depth", configData.get_value("Video", "ColorDepth", true))
	ditheringShader.set_shader_parameter("resolution_scale", configData.get_value("Video", "ResolutionScale", true))
	
	
	var bus_index = AudioServer.get_bus_index("Weapons")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(configData.get_value("Audio", "Weapons", 0.5)))
	bus_index = AudioServer.get_bus_index("Environment")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(configData.get_value("Audio", "Environment", 0.5)))
	bus_index = AudioServer.get_bus_index("Effects")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(configData.get_value("Audio", "Effects", 0.5)))

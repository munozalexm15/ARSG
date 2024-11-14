extends Node

@onready var ditheringShader = preload("res://GameResources/Materials/Dithering_Shader_Material.tres") 

var configData : ConfigFile
var isOnlineMatch : bool

signal configurationUpdated

var allowed_input_actions = {
	"Forward" : KEY_W,
	"Backwards" : KEY_S,
	"Left" : KEY_A,
	"Right" : KEY_D,
	"Jump" : KEY_SPACE,
	"Sprint" : KEY_SHIFT,
	"Crouch" : KEY_CTRL,
	"Next Weapon" : MOUSE_BUTTON_WHEEL_UP,
	"Previous Weapon" : MOUSE_BUTTON_WHEEL_DOWN,
	"Fire" : MOUSE_BUTTON_LEFT,
	"ADS": MOUSE_BUTTON_RIGHT,
	"Reload": KEY_R,
	"Interact" : KEY_F,
	"Grenade" : KEY_G,
	"FireSelection": KEY_X,
	"Perspective" : KEY_H,
}


# Called when the node enters the scene tree for the first time.
func _ready():
	isOnlineMatch = false
	configData = ConfigFile.new()
	var loadedData = configData.load("res://GameSettings.cfg")
	if loadedData == OK:
		loadGameSettings()
		configurationUpdated.emit()
	
	if loadedData != OK:
		configData.set_value("Video", "Resolution", Vector2i(1920, 1080))
		configData.set_value("Video", "isFullscreen", true)
		configData.set_value("Video", "hasDithering", true)
		configData.set_value("Video", "V-Sync", true)
		configData.set_value("Video", "ColorDepth", 5)
		configData.set_value("Video", "ResolutionScale", 1)
		
		configData.set_value("Audio", "Weapons", 1)
		configData.set_value("Audio", "WeaponSliderValue", 1)
		configData.set_value("Audio", "Environment", 1)
		configData.set_value("Audio", "EnvironmentSliderValue", 1)
		configData.set_value("Audio", "Effects", 1)
		configData.set_value("Audio", "EffectsSliderValue", 1)
		
		for key in allowed_input_actions:
			configData.set_value("Controls", key, allowed_input_actions.get(key))
		
		
		#configData.set_value("Controls", "AimMouseSensibility", 1)
		#configData.set_value("Controls", "Forward", "W (Physical)")
		#configData.set_value("Controls", "Backwards", "S (Physical)")
		#configData.set_value("Controls", "Left", "A (Physical)")
		#configData.set_value("Controls", "Right", "D (Physical)")
		#configData.set_value("Controls", "Jump", "Space (Physical)")
		#configData.set_value("Controls", "Sprint", "Shift (Physical)")
		#configData.set_value("Controls", "Crouch", "Ctrl (Physical)")
		#configData.set_value("Controls", "Next Weapon", "Mouse Wheel Up - All Devices")
		#configData.set_value("Controls", "Previous Weapon", "Mouse Wheel Down - All Devices")
		#configData.set_value("Controls", "Primary weapon", "1 (Physical)")
		#configData.set_value("Controls", "Secondary weapon", "2 (Physical)")
		#configData.set_value("Controls", "Fire", "Left Mouse Button - All Devices")
		#configData.set_value("Controls", "Reload", "R (Physical)")
		#configData.set_value("Controls", "ADS", "Right Mouse Button - All Devices")
		#configData.set_value("Controls", "Interact", "F (Physical)")
		#configData.set_value("Controls", "FireSelection", "X (Physical)")
		#configData.set_value("Controls", "Perspective", "H (Physical)")
		#configData.set_value("Controls", "Scoreboard", "Tab (Physical)")
		#configData.set_value("Controls", "Open Chat", "T (Physical)")
		#configData.set_value("Controls", "Send Message", "Enter (Physical)")
		
		configData.save("res://GameSettings.cfg")


func loadGameSettings():
	#FULLSCREEN---------------------------------------------------------------------
	if configData.get_value("Video", "isFullscreen", true) == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	get_window().size = configData.get_value("Video", "Resolution", Vector2i(1024, 768))
	
	for key in allowed_input_actions:
		var input : InputEventKey = InputEventKey.new()
		input.keycode = allowed_input_actions.get(key)
		InputMap.action_erase_events(key)
		InputMap.action_add_event(key, input)
		if input.keycode < 10:
			var inputMouse : InputEventMouseButton = InputEventMouseButton.new()
			inputMouse.button_index = allowed_input_actions.get(key)
			InputMap.action_erase_events(key)
			InputMap.action_add_event(key, inputMouse)
	
	#DITHERING---------------------------------------------------------------------
	
	if configData.get_value("Video", "hasDithering", true) == true:
		ditheringShader.set_shader_parameter("dithering", true)
	else:
		ditheringShader.set_shader_parameter("dithering", false)
	
	#V-SYNC---------------------------------------------------------------------
	if configData.get_value("Video", "V-Sync", true) == true:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	
	ditheringShader.set_shader_parameter("color_depth", configData.get_value("Video", "ColorDepth", true))
	ditheringShader.set_shader_parameter("resolution_scale", configData.get_value("Video", "ResolutionScale", true))
	
	
	#AUDIO---------------------------------------------------------------------
	var bus_index = AudioServer.get_bus_index("Weapons")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(configData.get_value("Audio", "Weapons", 0.5)))
	bus_index = AudioServer.get_bus_index("Environment")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(configData.get_value("Audio", "Environment", 0.5)))
	bus_index = AudioServer.get_bus_index("Effects")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(configData.get_value("Audio", "Effects", 0.5)))

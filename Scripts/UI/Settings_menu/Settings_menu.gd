class_name SettingsMenu
extends VBoxContainer

@export var button_hover_SFX : AudioStreamOggVorbis
@export var button_press_SFX : AudioStreamOggVorbis

@onready var optionsMainContainer : VBoxContainer = $"."
@onready var animationPlayer : AnimationPlayer = $AnimationPlayer

#Visual options
@onready var visualOptionsContainer : HBoxContainer = $VisualOptionsContainer/VisualOptions

@onready var resolutionDropdown : OptionButton = $VisualOptionsContainer/VisualOptions/VBoxContainer2/ResolutionList
@onready var vsyncButton : CheckBox = $"VisualOptionsContainer/VisualOptions/VBoxContainer2/Vsync-Checkbox"
@onready var fullscrenButton : CheckBox = $"VisualOptionsContainer/VisualOptions/VBoxContainer2/Fullscreen-Checkbox"
@onready var resolutionScale_Slider : HSlider =$"VisualOptionsContainer/VisualOptions/VBoxContainer2/ResolutionScale-Slider"
@onready var hasDitheringButton : CheckBox = $"VisualOptionsContainer/VisualOptions/VBoxContainer2/HasDithering-Checkbox"
@onready var colorDepth_Slider : HSlider = $"VisualOptionsContainer/VisualOptions/VBoxContainer2/ColorDepth-Slider"

@export var ditheringMaterial : ShaderMaterial

var resolutions_dict : Dictionary = {"3040x2160" : Vector2i(3040, 2160),
									  "2560x1440": Vector2i(2560, 1440),
									  "1920x1080": Vector2i(1920, 1080),
									  "1600x900" : Vector2i(1600, 900),
									  "1440x900" : Vector2i(1440, 900),
									  "1366x768" : Vector2i(1366, 768),
									  "1200x720" : Vector2i(1200, 720),
									  "1024x600" : Vector2i(1024, 600),
									  "800x600" : Vector2i(800, 600)}

#Sounds
@onready var soundOptionsContainer : MarginContainer = $SoundOptionsContainer
@onready var weaponSounds_Slider : HSlider = $"SoundOptionsContainer/VisualOptions/VBoxContainer2/WeaponSounds-Slider"
@onready var environmentSounds_Slider : HSlider = $"SoundOptionsContainer/VisualOptions/VBoxContainer2/EnvironmentSounds-Slider"
@onready var effectsSounds_Slider : HSlider = $"SoundOptionsContainer/VisualOptions/VBoxContainer2/EffectsSounds-Slider"

#Controls
@onready var controlsOptionContainer : MarginContainer = $ControlsOptionsContainer
@onready var mapping_button_scene = preload("res://Scenes/UI/Settings_Menu/map_control_settings_button.tscn")
@onready var actionList : VBoxContainer = $ControlsOptionsContainer/VBoxContainer/ScrollContainer/MarginContainer/ActionsList
var is_remmaping = false
var action_to_remap = null
var remapping_button = null

var allowed_input_actions = {
	"Forward" : "Forward",
	"Backwards" : "Backwards",
	"Left" : "Left",
	"Right" : "Right",
	"Jump" : "Jump",
	"Sprint" : "Sprint",
	"Crouch" : "Crouch",
	"Next Weapon" : "Next Weapon",
	"Previous Weapon" : "Previous Weapon",
	"Fire" : "Fire",
	"Reload": "Reload",
	"ADS": "ADS",
	"Interact" : "Interact",
	"FireSelection": "Fire Selection",
	"Perspective" : "Perspective",
	"Scoreboard" : "Scoreboard",
	"Open Chat" : "Open Chat",
	"Send Message" : "Send Message"
}

var configData : ConfigFile

signal ConfigurationUpdate

# Called when the node enters the scene tree for the first time.
func _ready():
	configData = ConfigFile.new()
	var _loadedData = configData.load("res://GameSettings.cfg")
	if _loadedData == OK:
		loadSettings()
	
	create_action_list()
	addResolutions()
	
func addResolutions():
	var current_res : Vector2i = get_viewport().size
	var index = 0
	
	for res in resolutions_dict:
		resolutionDropdown.add_item(res, index)
		if resolutions_dict[res] == current_res:
			resolutionDropdown.select(index)
		
		index+=1

func loadSettings():
	weaponSounds_Slider.value = configData.get_value("Audio", "WeaponSliderValue", 1)
	effectsSounds_Slider.value = configData.get_value("Audio", "EffectsSliderValue", 1)
	environmentSounds_Slider.value = configData.get_value("Audio", "EnvironmentSliderValue", 1)
	colorDepth_Slider.value = configData.get_value("Video", "ColorDepth", 5)
	resolutionScale_Slider.value = configData.get_value("Video", "ResolutionScale", 2)
	fullscrenButton.button_pressed = configData.get_value("Video", "isFullscreen", false)
	hasDitheringButton.button_pressed = configData.get_value("Video", "hasDithering", false)
	vsyncButton.button_pressed = configData.get_value("Video", "V-Sync", false)

func _input(event):
	if is_remmaping == false:
		hide_menu()
	if is_remmaping:
		if (event is InputEventKey || event is InputEventMouseButton && event.pressed ):
			
			if event is InputEventMouseButton && event.double_click:
				event.double_click = false
			InputMap.action_erase_events(action_to_remap)
			InputMap.action_add_event(action_to_remap, event)
			remapping_button.find_child("InputLabel").text = event.as_text().trim_suffix(" (Physical)")
			
			is_remmaping = false
			action_to_remap = null
			remapping_button = null
			
			accept_event()

func hide_menu():
	if optionsMainContainer.visible == true:
		#animationPlayer.play("OpenOptions", -1, -2, true)
		#await animationPlayer.animation_finished
		pass

func set_resolution_text():
	var res_text = str(get_window().size.x) + "x" + str(get_window().size.y)
	resolutionDropdown.text = res_text

#VISUALS----------------------------------------------------------------------
func _on_resolution_list_item_selected(index):
	var res_size = resolutions_dict.get(resolutionDropdown.get_item_text(index))
	get_window().size = res_size
	configData.set_value("Video", "Resolution", res_size)
	configData.save("res://GameSettings.cfg")

func _on_fullscreen_checkbox_pressed():
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		set_resolution_text()
		configData.set_value("Video", "isFullscreen", true)
		fullscrenButton.button_pressed = true
	else:
		print("jeje")
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		set_resolution_text()
		configData.set_value("Video", "isFullscreen", false)
		fullscrenButton.button_pressed = false
	
	configData.set_value("Video", "Resolution", get_window().size)
	configData.save("res://GameSettings.cfg")
	GlobalData.configData = configData
	GlobalData.configurationUpdated.emit()


func _on_vsync_checkbox_pressed():
	if DisplayServer.window_get_vsync_mode() == DisplayServer.VSYNC_DISABLED:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
		configData.set_value("Video", "V-Sync", true)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		configData.set_value("Video", "V-Sync", false)
		
	configData.save("res://GameSettings.cfg")

func _on_has_dithering_checkbox_toggled(_toggled_on):
	if ditheringMaterial.get_shader_parameter("dithering") == false:
		ditheringMaterial.set_shader_parameter("dithering", true)
		configData.set_value("Video", "hasDithering", true)
	else:
		ditheringMaterial.set_shader_parameter("dithering", false)
		configData.set_value("Video", "hasDithering", false)
		
	configData.save("res://GameSettings.cfg")

func _on_color_depth_slider_value_changed(value):
	ditheringMaterial.set_shader_parameter("color_depth", value)
	configData.set_value("Video", "ColorDepth", value)
	configData.save("res://GameSettings.cfg")


func _on_visuals_button_pressed():
	SFXHandler.play_sfx(button_press_SFX, self, "Effects")
	
	soundOptionsContainer.hide()
	controlsOptionContainer.hide()
	visualOptionsContainer.show()

func _on_resolution_scale_slider_value_changed(value):
	ditheringMaterial.set_shader_parameter("resolution_scale", value)
	configData.set_value("Video", "ResolutionScale", value)
	configData.save("res://GameSettings.cfg")
	
#SOUND--------------------------------------------------------------------

func _on_sound_button_pressed():
	SFXHandler.play_sfx(button_press_SFX, self, "Effects")
	
	visualOptionsContainer.hide()
	controlsOptionContainer.hide()
	soundOptionsContainer.show()

func _on_effects_sounds_slider_value_changed(value):
	var bus_index = AudioServer.get_bus_index("Effects")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	configData.set_value("Audio", "EffectsSliderValue", value)
	configData.save("res://GameSettings.cfg")

func _on_environment_sounds_slider_value_changed(value):
	var bus_index = AudioServer.get_bus_index("Environment")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	configData.set_value("Audio", "EnvironmentSliderValue", value)
	configData.save("res://GameSettings.cfg")

func _on_weapon_sounds_slider_value_changed(value):
	var bus_index = AudioServer.get_bus_index("Weapons")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	configData.set_value("Audio", "WeaponSliderValue", value)
	configData.save("res://GameSettings.cfg")

#CONTROLS----------------------------------------------------------------
func _on_controls_button_pressed():
	SFXHandler.play_sfx(button_press_SFX, self, "Effects")
	
	visualOptionsContainer.hide()
	soundOptionsContainer.hide()
	controlsOptionContainer.show()

func create_action_list():
	InputMap.load_from_project_settings()
	for item in actionList.get_children():
		item.queue_free()
	
	for action in allowed_input_actions:
		var button : Button = mapping_button_scene.instantiate()
		var actionLabel : Label = button.find_child("LabelAction")
		var inputLabel : Label = button.find_child("InputLabel")
		
		actionLabel.text = allowed_input_actions[action]
		
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			inputLabel.text = events[0].as_text().trim_suffix(" (Physical)")
		else:
			inputLabel.text = ""
		
		actionList.add_child(button)
		button.pressed.connect(_on_input_button_pressed.bind(button, action))
	
func _on_input_button_pressed(button : Button, action):
	if !is_remmaping:
		is_remmaping = true
		action_to_remap = action
		remapping_button = button
		button.find_child("InputLabel").text = "Press a key to bind..."


func _on_button_2_pressed() -> void:
	create_action_list()

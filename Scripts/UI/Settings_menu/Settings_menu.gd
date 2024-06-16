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

var configData : ConfigFile

# Called when the node enters the scene tree for the first time.
func _ready():
	optionsMainContainer.visible = false
	configData = ConfigFile.new()
	var loadedData = configData.load("res://GameSettings.cfg")
	if loadedData == OK:
		loadDefaultSettings()
		addResolutions()

func loadDefaultSettings():
	
	#AUDIO
	weaponSounds_Slider.value = configData.get_value("Audio", "WeaponsSliderValue", 1)
	effectsSounds_Slider.value = configData.get_value("Audio", "EffectsSliderValue", 1)
	environmentSounds_Slider.value = configData.get_value("Audio", "EnvironmentSliderValue", 1)
	
	#VSYNC
	if DisplayServer.window_get_vsync_mode() == DisplayServer.VSYNC_DISABLED:
		vsyncButton.button_pressed = false
	else:
		vsyncButton.button_pressed = true
	
	#Fullscreen
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
		fullscrenButton.button_pressed = false
	else:
		fullscrenButton.button_pressed = true
	
	#Dithering Filter
	if ditheringMaterial.get_shader_parameter("dithering") == true:
		hasDitheringButton.button_pressed = true
	else:
		hasDitheringButton.button_pressed = false
	
	resolutionScale_Slider.value = ditheringMaterial.get_shader_parameter("resolution_scale")

func addResolutions():
	var current_res : Vector2i = get_viewport().size
	var index = 0
	
	for res in resolutions_dict:
		resolutionDropdown.add_item(res, index)
		if resolutions_dict[res] == current_res:
			resolutionDropdown.select(index)
		
		index+=1

func _input(event):
	hide_menu()

func hide_menu():
	if optionsMainContainer.visible == true:
		#animationPlayer.play("OpenOptions", -1, -2, true)
		#await animationPlayer.animation_finished
		pass

func set_resolution_text():
	var res_text = str(get_window().size.x) + "x" + str(get_window().size.y)
	resolutionDropdown.text = res_text

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_2_pressed():
	SFXHandler.play_sfx(button_press_SFX, self, "Effects")
	hide_menu()

func _on_button_2_mouse_entered():
	SFXHandler.play_sfx(button_hover_SFX, self, "Effects")

func _on_exit_button_pressed():
	SFXHandler.play_sfx(button_press_SFX, self, "Effects")
	get_tree().quit()

func _on_exit_button_mouse_entered():
	SFXHandler.play_sfx(button_hover_SFX, self, "Effects")

#VISUALS----------------------------------------------------------------------
func _on_resolution_list_item_selected(index):
	var size = resolutions_dict.get(resolutionDropdown.get_item_text(index))
	get_window().size = size
	configData.set_value("Video", "Resolution", size)
	configData.save("res://GameSettings.cfg")

func _on_fullscreen_checkbox_pressed():
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		set_resolution_text()
		configData.set_value("Video", "isFullscreen", true)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		set_resolution_text()
		configData.set_value("Video", "isFullscreen", false)


func _on_vsync_checkbox_pressed():
	if DisplayServer.window_get_vsync_mode() == DisplayServer.VSYNC_DISABLED:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
		configData.set_value("Video", "V-Sync", true)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		configData.set_value("Video", "V-Sync", true)
		
	configData.save("res://GameSettings.cfg")

func _on_has_dithering_checkbox_toggled(toggled_on):
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
	soundOptionsContainer.hide()
	controlsOptionContainer.hide()
	visualOptionsContainer.show()

#SOUND--------------------------------------------------------------------

func _on_sound_button_pressed():
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
	configData.set_value("Audio", "WeaponsSliderValue", value)
	configData.save("res://GameSettings.cfg")

#CONTROLS----------------------------------------------------------------
func _on_controls_button_pressed():
	visualOptionsContainer.hide()
	soundOptionsContainer.hide()
	controlsOptionContainer.show()


func _on_resolution_scale_slider_value_changed(value):
	ditheringMaterial.set_shader_parameter("resolution_scale", value)
	configData.set_value("Video", "ResolutionScale", value)
	configData.save("res://GameSettings.cfg")

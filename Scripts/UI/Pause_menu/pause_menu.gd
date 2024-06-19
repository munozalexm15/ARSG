class_name Pause_Menu
extends Control

#warp mouse es util para setear la posicion del raton y no de esos tirones al pausar el juego

#if is playing multiplayer, not enable menu if exiting the game window
var isMultiplayer : bool = false

@onready var animationPlayer : AnimationPlayer = $AnimationPlayer

@export var button_hover_SFX : AudioStreamOggVorbis
@export var button_press_SFX : AudioStreamOggVorbis

@onready var pauseMenu : VBoxContainer = $HBoxContainer2/MarginContainer/PauseMenu
@onready var optionsNavigation : HBoxContainer = $VBoxContainer/MarginContainer/OptionsNavigation

@onready var optionsMainContainer : SettingsMenu = $VBoxContainer

@onready var ditheringMaterial : ShaderMaterial = GlobalData.ditheringShader

# Called when the node enters the scene tree for the first time.
func _ready():
	isMultiplayer = false
	visible = false

func _input(_event):
	if isMultiplayer:
		hide()

	if Input.is_action_just_pressed("Pause"):
		hide_menu()
	
func hide_menu():
	if optionsMainContainer.visible:
		optionsMainContainer.animationPlayer.play("OpenOptions", -1, -2, true)
		await optionsMainContainer.animationPlayer.animation_finished
		optionsMainContainer.hide()
	animationPlayer.play("OpenMenu", -1, -2, true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_viewport().set_input_as_handled()
	await animationPlayer.animation_finished
	if get_tree().paused:
		get_tree().paused = false
		hide()

func _on_settings_button_mouse_entered():
	SFXHandler.play_sfx(button_hover_SFX, self, "Effects")
	
func _on_settings_button_pressed():
	SFXHandler.play_sfx(button_press_SFX, self, "Effects")
	if optionsMainContainer.visible:
		optionsMainContainer.animationPlayer.play("OpenOptions", -1, -2, true)
		await optionsMainContainer.animationPlayer.animation_finished
		optionsMainContainer.hide()
	else:
		optionsMainContainer.show()
		optionsMainContainer.soundOptionsContainer.hide()
		optionsMainContainer.controlsOptionContainer.hide()
		optionsMainContainer.animationPlayer.play("OpenOptions", -1, 2, false)
		await optionsMainContainer.animationPlayer.animation_finished
		optionsMainContainer.visualOptionsContainer.show()

func _on_continue_button_pressed():
	SFXHandler.play_sfx(button_press_SFX, self, "Effects")
	hide_menu()

func _on_continue_button_mouse_entered():
	SFXHandler.play_sfx(button_hover_SFX, self, "Effects")


func _on_exit_button_pressed():
	SFXHandler.play_sfx(button_press_SFX, self, "Effects")
	get_tree().quit()


func _on_exit_button_mouse_entered():
	SFXHandler.play_sfx(button_hover_SFX, self, "Effects")

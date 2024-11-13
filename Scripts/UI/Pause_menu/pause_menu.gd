class_name Pause_Menu
extends Control

#warp mouse es util para setear la posicion del raton y no de esos tirones al pausar el juego

#if is playing multiplayer, not enable menu if exiting the game window
var isMultiplayer : bool = false

@onready var animationPlayer : AnimationPlayer = $AnimationPlayer

@export var button_hover_SFX : AudioStreamOggVorbis
@export var button_press_SFX : AudioStreamOggVorbis

@onready var pauseMenu : VBoxContainer = $HBoxContainer2/MarginContainer/PauseMenu

@onready var optionsMainContainer : SettingsMenu = $OptionsControl

@onready var ditheringMaterial : ShaderMaterial = GlobalData.ditheringShader

var player : Player = null

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false

func _input(_event):
	pass
	#if Input.is_action_just_pressed("Pause") and not animationPlayer.is_playing():
		#hide_menu()
	
func hide_menu():
	if optionsMainContainer.visible:
		optionsMainContainer.animationPlayer.play("OpenOptions", -1, -2, true)
		await optionsMainContainer.animationPlayer.animation_finished
		optionsMainContainer.hide()
		
	animationPlayer.play("OpenMenu", -1, -2, true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
	await animationPlayer.animation_finished
	player.isPauseMenuOpened = false
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
	Network.player_left.rpc(multiplayer.get_unique_id())
	get_tree().quit()


func _on_exit_button_mouse_entered():
	SFXHandler.play_sfx(button_hover_SFX, self, "Effects")


func _on_exit_match_button_pressed():
	pass


func _on_change_weapon_button_pressed() -> void:
	player.weaponSelectionMenu.visible = true
	visible = false

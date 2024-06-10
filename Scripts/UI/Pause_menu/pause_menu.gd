class_name Pause_Menu
extends Control

#warp mouse es util para setear la posicion del raton y no de esos tirones al pausar el juego

#if is playing multiplayer, not enable menu if exiting the game window
var isMultiplayer : bool = false

@onready var animationPlayer : AnimationPlayer = $AnimationPlayer

@export var button_hover_SFX : AudioStreamOggVorbis
@export var button_press_SFX : AudioStreamOggVorbis

# Called when the node enters the scene tree for the first time.
func _ready():
	isMultiplayer = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	if isMultiplayer:
		hide()
	
	if Input.is_action_just_pressed("Pause"):
		hide_menu()

func _on_button_2_pressed():
	SFXHandler.play_sfx(button_press_SFX, self)
	hide_menu()
	
func hide_menu():
	animationPlayer.play("OpenMenu", -1, -1, true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_viewport().set_input_as_handled()
	await animationPlayer.animation_finished
	if get_tree().paused:
		get_tree().paused = false
		hide()


func _on_button_2_mouse_entered():
	SFXHandler.play_sfx(button_hover_SFX, self)

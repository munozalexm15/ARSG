class_name Pause_Menu
extends Control

#warp mouse es util para setear la posicion del raton y no de esos tirones al pausar el juego

#if is playing multiplayer, not enable menu if exiting the game window
var isMultiplayer : bool = false

@onready var animationPlayer : AnimationPlayer = $AnimationPlayer

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
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		get_viewport().set_input_as_handled()
		if get_tree().paused:
			get_tree().paused = false
			hide()
		

func _on_ui_mouse_exited():
	if isMultiplayer:
		return
	
	show()
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED

func _on_ui_mouse_entered():
	if isMultiplayer:
		return
		
	hide()
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

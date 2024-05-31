extends Control

@onready var animationPlayer : AnimationPlayer = $AnimationPlayer
@onready var startContainer : CenterContainer = $StartContainer
@onready var mainMenuContainer : VBoxContainer = $HBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	mainMenuContainer.visible = false
	startContainer.visible = true
	animationPlayer.play("Breathing_Anim")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("Jump"):
		animationPlayer.play("Startup_Anim")

extends Node3D

@export var animationNode := NodePath()
@onready var animationPlayer : AnimationPlayer = get_node(animationNode)

@export var playerNode := NodePath()
@onready var player : Player = get_node(playerNode)

var mouse_Movement
var sway_threshold = 5
var sway_lerp = 5

@export var sway_left : Vector3
@export var sway_right : Vector3
@export var sway_normal : Vector3

# Called when the node enters the scene tree for the first time.
func _ready():
	animationPlayer.play("Idle")

func _input(event):
	if event is InputEventMouseMotion:
		mouse_Movement = -event.relative.x

func _process(delta):
	if mouse_Movement != null and !player.isColliding:
		if mouse_Movement > sway_threshold:
			rotation = rotation.lerp(sway_left, sway_lerp * delta)
		elif mouse_Movement < - sway_threshold:
			rotation = rotation.lerp(sway_right, sway_lerp * delta)
		else:
			rotation = rotation.lerp(sway_normal, sway_lerp * delta)

func _physics_process(delta):
	pass

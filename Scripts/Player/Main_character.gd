class_name Player
extends CharacterBody3D

@export var cameraNode := NodePath()
@onready var head : Node3D = get_node(cameraNode)

@export var standing_collisionNode := NodePath()
@onready var standing_CollisionShape : CollisionShape3D = get_node(standing_collisionNode)

@export var crouching_collisionNode := NodePath()
@onready var crouching_CollisionShape : CollisionShape3D = get_node(crouching_collisionNode)

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

#---MOVEMENT
var input_direction: Vector2 = Vector2.ZERO
var direction = Vector3.ZERO
var lerp_speed = 5

var curr_speed = 5.0

const walk_speed = 5.0
const run_speed = 10.0
const crouch_speed = 3.0

const jump_force = 4.5

#---OTHER
const mouse_sensibility = 0.4
var crouching_depth = 0.5
var initialHead_pos = 0.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	initialHead_pos = head.position.y

func _input(event):
	#If mouse is moving
	if event is InputEventMouseMotion:
		#rotate player x axis ONLY
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensibility))
		#rotate camera y axis and limit its rotation
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sensibility))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func _physics_process(delta):
	input_direction = Input.get_vector("Left", "Right", "Forward", "Backwards")
	direction = lerp(direction, transform.basis * Vector3(input_direction.x, 0, input_direction.y).normalized(), delta * lerp_speed)
	#NON SMOOTH DIRECTION : direction = (transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()
	
	if !Input.is_action_pressed("Crouch"):
		head.position.y = lerp(head.position.y, initialHead_pos, delta * lerp_speed)
	move_and_slide()

func _on_state_machine_transitioned(state_name, old_state):
	pass
	#print("Last state: " , old_state , "   ---   New state: " , state_name)

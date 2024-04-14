class_name Player
extends CharacterBody3D

@export var bobbingNode := NodePath()
@onready var eyes : Node3D = get_node(bobbingNode)

@export var armsNode := NodePath()
@onready var arms : Node3D = get_node(armsNode)

@export var standing_collisionNode := NodePath()
@onready var standing_CollisionShape : CollisionShape3D = get_node(standing_collisionNode)

@export var crouching_collisionNode := NodePath()
@onready var crouching_CollisionShape : CollisionShape3D = get_node(crouching_collisionNode)

@export var standingRaycastNode := NodePath()
@onready var standingRaycast : RayCast3D = get_node(standingRaycastNode)

@export var animationNode := NodePath()
@onready var animationPlayer : AnimationPlayer = get_node(animationNode)

@export var cameraNode := NodePath()
@onready var camera : Camera3D = get_node(cameraNode)

@export var hudNode := NodePath()
@onready var hud : CanvasLayer = get_node(hudNode)

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

#---MOVEMENT
var input_direction: Vector2 = Vector2.ZERO
var direction = Vector3.ZERO
var lerp_speed = 10

var curr_speed = 2.0

const walk_speed = 2.0
const run_speed = 10.0
const crouch_speed = 1

const jump_force = 4.5
var lerp_air_speed = 3

#---OTHER
var state
const mouse_sensibility = 0.4
var crouching_depth = 0.8
var initialHead_pos = 0.0
var initialHands_pos = 0.0

var lerpHandsPosition = 0.0
var newDirection = 0
var distanceCheck = 1
var isColliding = false

#--- Head bobbing
const hb_speeds = {"crouch_speed"= 10.0, "walk_speed" = 15.0, "sprint_speed" = 22.0, "idle_speed"= 10.0}

#---------In meters
const hb_intensities = {"crouch_speed"= 0.005, "walk_speed" = 0.01, "sprint_speed" = 0.02, "idle_speed" = 0.005}

#---------Index value for assign function (wave)
var headBobbing_index = 0.0
var headBobbing_vector = Vector2.ZERO
var headBobbing_curr_intensity = 0.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	initialHead_pos = eyes.position.y
	initialHands_pos = arms.position.y

func _input(event):
	#If mouse is moving
	if event is InputEventMouseMotion:
		#rotate player x axis ONLY
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensibility))
		#rotate camera y axis and limit its rotation
		eyes.rotate_x(deg_to_rad(-event.relative.y * mouse_sensibility))
		eyes.rotation.x = clamp(eyes.rotation.x, deg_to_rad(-89), deg_to_rad(89))
		
func _physics_process(delta):
	input_direction = Input.get_vector("Left", "Right", "Forward", "Backwards")
	#NON SMOOTH DIRECTION : direction = (transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()
	
	if (!Input.is_action_pressed("Crouch") or !is_on_floor()) and !standingRaycast.is_colliding():
		eyes.position.y = lerp(eyes.position.y, initialHead_pos, delta * lerp_speed)
		
		arms.position.y = lerp(arms.position.y, initialHands_pos, delta * lerp_speed)
	
	if is_on_floor() and input_direction != Vector2.ZERO:
		direction = lerp(direction, transform.basis * Vector3(input_direction.x, 0, input_direction.y).normalized(), delta * lerp_speed)
		headBobbing_vector.y =  sin(headBobbing_index)
		headBobbing_vector.x =  sin(headBobbing_index/2)+0.5

		eyes.position.y = lerp(eyes.position.y, headBobbing_vector.y * (headBobbing_curr_intensity / 2.0), delta * lerp_speed)
		eyes.position.x = lerp(eyes.position.x, headBobbing_vector.x * headBobbing_curr_intensity, delta * lerp_speed)
		
		arms.position.y = lerp(arms.position.y, headBobbing_vector.y * (headBobbing_curr_intensity / 2.0), delta * lerp_speed)
		arms.position.x = lerp(arms.position.x, headBobbing_vector.x * headBobbing_curr_intensity, delta * lerp_speed)
	
	elif is_on_floor() and input_direction == Vector2.ZERO:
		
		direction = lerp(direction, transform.basis * Vector3(input_direction.x, 0, input_direction.y).normalized(), delta * lerp_air_speed)
		eyes.position.y = lerp(eyes.position.y, 0.0, delta * lerp_speed)
		eyes.position.x = lerp(eyes.position.x, 0.0, delta * lerp_speed)
		
		arms.position.y = lerp(arms.position.y, 0.0, delta * lerp_speed)
		arms.position.x = lerp(arms.position.x, 0.0, delta * lerp_speed)
	
	
	#Check for frontal collisions with a wall
	_checkCollisionWithWall()
	
	move_and_slide()

func _on_state_machine_transitioned(state_name, old_state):
	state = state_name
	#print("Last state: " , old_state , "   ---   New state: " , state_name)

func _checkCollisionWithWall():
	var space_state = get_world_3d().direct_space_state
	var mousepos = get_viewport().get_mouse_position()
	
	var origin = camera.project_ray_origin(mousepos)
	var end = origin + camera.project_ray_normal(mousepos) * distanceCheck
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true
	query.exclude = [self]
	
	var result = space_state.intersect_ray(query)
	if result.has("position"):
		var coll_point = result.position
		var hit_Distance = origin.distance_to(result.position)
		lerpHandsPosition = 1 - (hit_Distance / distanceCheck)
		lerpHandsPosition= clamp(lerpHandsPosition, 0, 1)
		isColliding = true
		
	else:
		isColliding = false
		if lerpHandsPosition > 0:
			lerpHandsPosition -= 0.05

	arms.rotation.z = lerp_angle(
	deg_to_rad(0),
	deg_to_rad(-45.0), 
	lerpHandsPosition)
	
	arms.rotation.x = lerp_angle(
	deg_to_rad(0),
	deg_to_rad(-45.0), 
	lerpHandsPosition)


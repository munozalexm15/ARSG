class_name Player
extends CharacterBody3D


signal challenge

signal step

@export var bobbingNode := NodePath()
@onready var eyes : Node3D = get_node(bobbingNode)

@export var armsNode := NodePath()
@onready var arms : Arms = get_node(armsNode)

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
@onready var hud : HUD = get_node(hudNode)

@export var pauseMenuNode := NodePath()
@onready var pauseMenu : Pause_Menu = get_node(pauseMenuNode)


@onready var state_machine : StateMachine = $StateMachine
@onready var groundCheck_Raycast : RayCast3D = $GroundCheckRaycast
@onready var ASP_Footsteps : AudioStreamPlayer3D = $ASP_footsteps

var configData : ConfigFile

var defaultGravity = ProjectSettings.get_setting("physics/3d/default_gravity")
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
var isClimbing = false
#--- Head bobbing
const hb_speeds = {"crouch_speed"= 10.0, "walk_speed" = 15.0, "sprint_speed" = 22.0, "idle_speed"= 10.0}

#---------In meters
const hb_intensities = {"crouch_speed"= 0.005, "walk_speed" = 0.01, "sprint_speed" = 0.06, "idle_speed" = 0.005}

#---------Index value for assign function (wave)
var headBobbing_index = 0.0
var headBobbing_vector = Vector2.ZERO
var headBobbing_curr_intensity = 0.0

var health: float = 75

var seeing_ally : bool = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	initialHead_pos = eyes.position.y
	initialHands_pos = arms.position.y
	hud.animationPlayer.play("swap_gun")
	pauseMenu.visible = false
	
	##WIP, this goes on the main menu once it is done
	configData = ConfigFile.new()
	var loadedData = configData.load("res://GameSettings.cfg")
	if loadedData != OK:
		configData.set_value("Video", "Resolution", Vector2i(1920, 1080))
		configData.set_value("Video", "isFullscreen", true)
		configData.set_value("Video", "hasDithering", true)
		configData.set_value("Video", "V-Sync", true)
		configData.set_value("Video", "ColorDepth", 5)
		configData.set_value("Video", "ResolutionScale", 2)
		configData.set_value("Audio", "Weapons", 1)
		configData.set_value("Audio", "WeaponSliderValue", 1)
		configData.set_value("Audio", "Environment", 1)
		configData.set_value("Audio", "EnvironmentSliderValue", 1)
		configData.set_value("Audio", "Effects", 1)
		configData.set_value("Audio", "EffectsSliderValue", 1)
		configData.save("res://GameSettings.cfg")
	
	loadGameSettings()

func _input(event : InputEvent):
	#If mouse is moving
	if event is InputEventMouseMotion:
		#rotate player x axis ONLY
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensibility))
		#rotate camera y axis and limit its rotation
		eyes.rotate_x(deg_to_rad(-event.relative.y * mouse_sensibility))
		eyes.rotation.x = clamp(eyes.rotation.x, deg_to_rad(-89), deg_to_rad(89))
		
	if Input.is_action_just_pressed("Pause") and not get_tree().paused:
		pauseMenu.show()
		pauseMenu.animationPlayer.play("OpenMenu", -1, 2, false)
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
		get_tree().paused = not get_tree().paused

func _physics_process(delta):
	if health < 100:
		updateHealth()
	
	input_direction = Input.get_vector("Left", "Right", "Forward", "Backwards")
	#NON SMOOTH DIRECTION : direction = (transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()
	
	if (!Input.is_action_pressed("Crouch") or !is_on_floor()) and !standingRaycast.is_colliding():
		eyes.position.y = lerp(eyes.position.y, initialHead_pos, delta * lerp_speed)
		arms.position.y = lerp(arms.position.y, initialHands_pos, delta * lerp_speed)
	
	if is_on_floor() and input_direction != Vector2.ZERO:
		direction = lerp(direction, transform.basis * Vector3(input_direction.x, 0, input_direction.y).normalized(), delta * lerp_speed)
		headBobbing_vector.y =  sin(headBobbing_index)
		headBobbing_vector.x =  sin(headBobbing_index/2)+0.5

		if groundCheck_Raycast.is_colliding() and headBobbing_vector.y < -0.98 and not ASP_Footsteps.playing:
			var collision : GroundData = groundCheck_Raycast.get_collider().groundData
			var sound : AudioStreamOggVorbis = collision.walk_sound.pick_random()
			ASP_Footsteps.stream = sound
			ASP_Footsteps.play()
		
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
	if arms.state_machine.state.name != "Melee":
		_checkCollisionWithWall()
	else:
		arms.position.z = 0
	leaning(delta)
	move_and_slide()
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider().name == "Ladder" and !isClimbing and !is_on_floor():
			isClimbing = true
			if state != "Climb":
				state_machine.transition_to("Climb")
	
	if  get_slide_collision_count() == 0:
		isClimbing = false

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

	if result and result.collider.is_in_group("WeaponCollisionException"):
		return
		
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
	
	arms.position.z = lerp_angle(
	deg_to_rad(0),
	deg_to_rad(25.0),
	lerpHandsPosition)

func leaning(delta):
	if Input.is_action_pressed("Lean Left") and !Input.is_action_pressed("Lean Right"):
		rotation_degrees.z = lerp(rotation_degrees.z, 15.0, delta * 5)
	elif  !Input.is_action_pressed("Lean Left") and Input.is_action_pressed("Lean Right"):
		rotation_degrees.z = lerp(rotation_degrees.z, -15.0, delta * 5)
	elif (Input.is_action_pressed("Lean Left") and Input.is_action_pressed("Lean Right")) or (!Input.is_action_pressed("Lean Left") and !Input.is_action_pressed("Lean Right")):
		rotation_degrees.z = lerp(rotation_degrees.z, 0.0, delta * 5)

##play swap weapon hands animation and show weapon
func updateHealth():
	await get_tree().create_timer(3).timeout
	health += 0.01
	hud.healthBar.value = health


func _on_interact_ray_button_pressed():
	hud.pointsContainer.visible = true
	hud.timerContainer.visible = true
	challenge.emit()

func loadGameSettings():
	get_window().size = configData.get_value("Video", "Resolution", Vector2i(1024, 768))
	
	if configData.get_value("Video", "isFullscreen", true) == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	if configData.get_value("Video", "hasDithering", true) == true:
		pauseMenu.ditheringMaterial.set_shader_parameter("dithering", true)
	else:
		pauseMenu.ditheringMaterial.set_shader_parameter("dithering", false)
	
	if configData.get_value("Video", "V-Sync", true) == true:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	
	pauseMenu.ditheringMaterial.set_shader_parameter("color_depth", configData.get_value("Video", "ColorDepth", true))
	pauseMenu.ditheringMaterial.set_shader_parameter("resolution_scale", configData.get_value("Video", "ResolutionScale", true))
	
	
	var bus_index = AudioServer.get_bus_index("Weapons")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(configData.get_value("Audio", "Weapons", 0.5)))
	bus_index = AudioServer.get_bus_index("Environment")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(configData.get_value("Audio", "Environment", 0.5)))
	bus_index = AudioServer.get_bus_index("Effects")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(configData.get_value("Audio", "Effects", 0.5)))

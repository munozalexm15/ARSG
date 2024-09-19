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

var pauseMenu : Pause_Menu 
var weaponSelectionMenu : WeaponSelection_Menu

@onready var state_machine : StateMachine = $StateMachine
@onready var groundCheck_Raycast : RayCast3D = $GroundCheckRaycast
@onready var ASP_Footsteps : AudioStreamPlayer3D = $ASP_footsteps
@onready var player_body : PlayerSkeleton = $PlayerSkeleton

var hit_indicator_scene = preload("res://Scenes/UI/hit_indicator.tscn")
var death_model = preload("res://Scenes/Characters/Player_DeathModel.tscn")

var hit_indicator_array : Array = []
var look_at_hit_indicator_array : Array = []

var configData : ConfigFile

var defaultGravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

#---MOVEMENT
var input_direction: Vector2 = Vector2.ZERO
var direction = Vector3.ZERO
var lerp_speed = 10

var curr_speed = 2.0

const walk_speed = 2.0
const run_speed = 7
const crouch_speed = 1

const jump_force = 4
var lerp_air_speed = 3

#---OTHER
var state
const mouse_sensibility = 0.4
var crouching_depth = 1.0
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

@onready var health_display : ProgressBar = $SubViewport/ProgressBar
var health: float = 100
var can_heal = false
var seeing_ally : bool = false

##MP RESPAWNS, TEAMS, DATA
var can_respawn = false
var time_to_respawn = 3.0
var team = ""


##SLOPES FIXES
@onready var stairBelowRaycast : RayCast3D = $StairsCheckerBehindRaycast3D
@onready var stairAheadRaycast : RayCast3D = $StairsCheckerAheadRaycast3D
const MAX_STEP_HEIGHT = 0.5
var _snapped_to_stairs_last_frame := false
var _last_frame_was_on_floor = -INF

func _enter_tree():
	set_multiplayer_authority(name.to_int())

func _ready():
	#modificar dependiendo del arma que tenga el jugador
	#si no es el que controla al player
	if not is_multiplayer_authority(): 
		arms.visible = false
		return
	
	health_display.value = health
	player_body.visible = false
	initialHead_pos = eyes.position.y
	initialHands_pos = arms.position.y
	hud.animationPlayer.play("swap_gun")
	camera.current = true

func _input(event : InputEvent):
	if not is_multiplayer_authority():
		return
	
	#If mouse is moving
	if event is InputEventMouseMotion:
		#rotate player x axis ONLY
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensibility))
		#rotate camera y axis and limit its rotation
		eyes.rotate_x(deg_to_rad(-event.relative.y * mouse_sensibility))
		eyes.rotation.x = clamp(eyes.rotation.x, deg_to_rad(-50), deg_to_rad(50))
	
	if Input.is_action_just_pressed("Pause") and not get_tree().paused:
		pauseMenu.show()
		pauseMenu.animationPlayer.play("OpenMenu", -1, 2, false)
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().paused = not get_tree().paused

func _physics_process(delta):
	if not is_multiplayer_authority():
		return
	
	if health < 35:
		hud.HurtScreenAnimationPlayer.play("low_hp")
	else:
		hud.HurtScreenAnimationPlayer.stop()
	
	health_display.value = health
	hud.healthBar.value = health
	
	if health < 100 and can_heal:
		updateHealth.rpc()
	
	#update_hitPosition()
	
	input_direction = Input.get_vector("Left", "Right", "Forward", "Backwards")
		#hardcoded sensibility
	eyes.rotate_x(Input.get_action_strength("LookUp") * 0.1)
	eyes.rotate_x(Input.get_action_strength("LookDown") * 0.1 * -1)
	rotate_y(Input.get_action_strength("LookLeft") * 0.1)
	rotate_y(Input.get_action_strength("LookRight") * 0.1 * -1)
	eyes.rotation.x = clamp(eyes.rotation.x, deg_to_rad(-50), deg_to_rad(50))
	#NON SMOOTH DIRECTION : direction = (transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()
	
	if (!Input.is_action_pressed("Crouch") or !is_on_floor()) and !standingRaycast.is_colliding():
		if not is_multiplayer_authority():
			return
		eyes.position.y = lerp(eyes.position.y, initialHead_pos, delta * lerp_speed)
		arms.position.y = lerp(arms.position.y, initialHands_pos, delta * lerp_speed)
	
	if is_on_floor(): 
		_last_frame_was_on_floor = Engine.get_physics_frames()
	
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
	if arms.state_machine.state.name != "Melee":
		_checkCollisionWithWall()
	else:
		arms.position.z = 0

#leaning ---------------------- WIP
	#leaning(delta)
	move_and_slide()
	_snap_down_to_stairs_check()
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider().name == "Ladder" and !isClimbing and !is_on_floor():
			isClimbing = true
			if state != "Climb":
				state_machine.transition_to("Climb")
	
	if  get_slide_collision_count() == 0:
		isClimbing = false

func _on_state_machine_transitioned(state_name, _old_state):
	state = state_name
	#print("Last state: " , old_state , "   ---   New state: " , state_name)

func is_surface_too_steep(normal : Vector3) -> bool:
	return normal.angle_to(Vector3.UP) > self.floor_max_angle
	
func _run_body_test_motion(from : Transform3D, motion : Vector3, result = null ) -> bool:
	if not result : result = PhysicsTestMotionResult3D.new() 
	var params = PhysicsTestMotionParameters3D.new()
	params.from = from
	params.motion = motion
	return PhysicsServer3D.body_test_motion(self.get_rid(), params, result)

func _snap_down_to_stairs_check() -> void:
	#si detectamos que el jugador estaba en el suelo justo antes y ahora no (esta bajando unas escaleras), consultaremos las fisicas para ver si
	# el jugador puede moverse a una posicion en la que no colisione (translate_y)
	var did_snap := false
	var floor_below : bool = stairBelowRaycast.is_colliding() and not is_surface_too_steep(stairBelowRaycast.get_collision_normal())
	var was_on_floor_last_frame = Engine.get_physics_frames() - _last_frame_was_on_floor == 1
	if not is_on_floor() and velocity.y <= 0 and (was_on_floor_last_frame or _snapped_to_stairs_last_frame) and floor_below:
		var body_test_result = PhysicsTestMotionResult3D.new()
		if _run_body_test_motion(self.global_transform, Vector3(0, -MAX_STEP_HEIGHT, 0), body_test_result):
			#si hay unas escaleras debajo
			var translate_y = body_test_result.get_travel().y
			self.position.y += translate_y
			apply_floor_snap()
			did_snap = true
	_snapped_to_stairs_last_frame = did_snap

func _snap_up_stairs_check(delta) -> bool:
	if not is_on_floor() and not _snapped_to_stairs_last_frame: return false
	# Don't snap stairs if trying to jump, also no need to check for stairs ahead if not moving
	if self.velocity.y > 0 or (self.velocity * Vector3(1,0,1)).length() == 0: return false
	var expected_move_motion = self.velocity * Vector3(1,0,1) * delta
	var step_pos_with_clearance = self.global_transform.translated(expected_move_motion + Vector3(0, MAX_STEP_HEIGHT * 2, 0))
	
	var down_check_result = KinematicCollision3D.new()
	if (self.test_move(step_pos_with_clearance, Vector3(0,-MAX_STEP_HEIGHT*2,0), down_check_result)
	and (down_check_result.get_collider().is_class("StaticBody3D") or down_check_result.get_collider().is_class("CSGShape3D"))):
		var step_height = ((step_pos_with_clearance.origin + down_check_result.get_travel()) - self.global_position).y
		print(step_height)
		if step_height > MAX_STEP_HEIGHT or step_height <= 0.001 or (down_check_result.get_position() - self.global_position).y > MAX_STEP_HEIGHT: return false
		stairAheadRaycast.global_position = down_check_result.get_position() + Vector3(0,MAX_STEP_HEIGHT,0) + expected_move_motion.normalized() * 0.1
		stairAheadRaycast.force_raycast_update()
		if stairAheadRaycast.is_colliding() and not is_surface_too_steep(stairAheadRaycast.get_collision_normal()):
			#_save_camera_pos_for_smoothing()
			self.global_position = step_pos_with_clearance.origin + down_check_result.get_travel()
			apply_floor_snap()
			_snapped_to_stairs_last_frame = true
			return true
	return false

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
		var _coll_point = result.position
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


func update_hitPosition():
	for hit_indicator : HitIndicator in hit_indicator_array:
		$Damage_indicator_lookAt.look_at(hit_indicator.instigator.global_transform.origin, Vector3.UP)
		hit_indicator.indicator_node.rotation = -$Damage_indicator_lookAt.rotation.y
	
	#if hit_indicator.visible:
		#$Damage_indicator_lookAt.look_at(hit_indicator.instigator.global_transform.origin, Vector3.UP)
		#hit_indicator.indicator_node.rotation = -$Damage_indicator_lookAt.rotation.y

@rpc("any_peer", "reliable", "call_local")
func assign_enemy_to_player_hit(instigator_player_id, affected_player_id):
	can_heal = false
	if animationPlayer.is_playing():
		animationPlayer.play("RESET")
	animationPlayer.play("hit")
	
	var hit_indicator : HitIndicator = hit_indicator_scene.instantiate()
	hit_indicator.connect("finished", updateIndicatorsArray)
	
	for p : Player in Network.game.players_node.get_children():
		if p.name.to_int() == instigator_player_id:
			hit_indicator.instigator = p
			hit_indicator_array.append(hit_indicator)
	
	for p : Player in Network.game.players_node.get_children():
		if p.name.to_int() == affected_player_id:
			
			p.add_child(hit_indicator)
			hit_indicator.animationPlayer.play("hit_anim")
			
			var look_at_node = Node3D.new()
			p.add_child(look_at_node)
			look_at_node.look_at(hit_indicator.instigator.global_transform.origin, Vector3.UP)
			hit_indicator.indicator_node.rotation = -look_at_node.rotation.y
			look_at_hit_indicator_array.append(look_at_node)
	
	await get_tree().create_timer(2).timeout
	can_heal = true

func updateIndicatorsArray(node):
	for index in range(hit_indicator_array.size() -1, -1, -1):
		var hit_node = hit_indicator_array[index]
		if hit_node == node:
			hit_indicator_array.remove_at(index)
			hit_node.queue_free()
			look_at_hit_indicator_array[index].queue_free()
			look_at_hit_indicator_array.remove_at(index)
	

##play swap weapon hands animation and show weapon
@rpc("any_peer", "call_local")
func updateHealth():
	health += 0.05

@rpc("any_peer", "call_local", "reliable")
func die_respawn(player_id, instigator_id):
	#actualizar los diccionarios de todos los jugadores con los stats
	var dead_guy = Network.game.players["player"+ str(player_id)]
	var killer = Network.game.players["player"+ str(instigator_id)]
	killer["score"] += 100
	killer["kills"] += 1
	dead_guy["deaths"] += 1
		
	health = 100
	set_collision_mask_value(3, false)
	visible= false
	Network.game.death_count += 1
	
	if Network.game == null:
		return
	
	var player : Player = null
	for p : Player in Network.game.players_node.get_children():
		if p.name.to_int() == player_id:
			player = p
	
	var deathModelScene = death_model.instantiate()
	deathModelScene.name = "body_count" + str(Network.game.death_count)
	
	Network.game.add_child(deathModelScene)
	deathModelScene.parent.rotation_degrees = rotation_degrees
	deathModelScene.position = position
	deathModelScene.position.y -= player_body.scale.y * 1.5
	deathModelScene.scale = Vector3(0.5, 0.5, 0.5)
	
	deathModelScene.animationPlayer.play("Death_BodyShot")
	
	var weaponPickupScene = load(player.arms.actualWeapon.weaponData.weaponPickupScene)
	var weaponPickupNode : WeaponInteractable = weaponPickupScene.instantiate()
	weaponPickupNode.id = randi()
	weaponPickupNode.position = deathModelScene.position
	weaponPickupNode.weaponData.reserveAmmo = player.arms.actualWeapon.weaponData.reserveAmmo
	weaponPickupNode.weaponData.bulletsInMag = player.arms.actualWeapon.weaponData.bulletsInMag
	Network.game.interactables_node.add_child(weaponPickupNode)
	
	global_position = Network.game.random_spawn()
	
	set_collision_mask_value(3, true)
	visible = true
	player.arms.actualWeapon.weaponData.bulletsInMag = player.arms.actualWeapon.weaponData.magSize
	Network.game.dashboardMatch.get_lobby_data.rpc()

func _on_interact_ray_button_pressed():
	hud.pointsContainer.visible = true
	hud.timerContainer.visible = true
	challenge.emit()

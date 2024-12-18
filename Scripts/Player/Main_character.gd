class_name Player
extends CharacterBody3D 

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

@export var thirdPersonCamNode := NodePath()
@onready var thirdPersonCam : Camera3D = get_node(thirdPersonCamNode)

@export var hudNode := NodePath()
@onready var hud : HUD = get_node(hudNode)

var pauseMenu : Pause_Menu 
var isPauseMenuOpened: bool = false
var weaponSelectionMenu : WeaponSelection_Menu

@onready var state_machine : StateMachine = $StateMachine
@onready var groundCheck_Raycast : RayCast3D = $GroundCheckRaycast
@onready var ASP_Footsteps : AudioStreamPlayer3D = $ASP_footsteps
@onready var player_body : PlayerSkeleton = $PlayerSkeleton
@onready var player_sounds : Node3D = $PlayerSounds
@onready var weapon_sounds : Node3D = $WeaponSounds

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
#--- Head bobbing
const hb_speeds = {"crouch_speed"= 10.0, "walk_speed" = 15.0, "sprint_speed" = 22.0, "idle_speed"= 10.0}

#---------In meters
const hb_intensities = {"crouch_speed"= 0.005, "walk_speed" = 0.01, "sprint_speed" = 0.06, "idle_speed" = 0.005}


#---------Index value for assign function (wave)
var headBobbing_index = 0.0
var headBobbing_vector = Vector2.ZERO
var headBobbing_curr_intensity = 0.0


var health: float = 0
var can_heal = false
var seeing_ally : bool = false
var is_dead = true

##MP RESPAWNS, TEAMS, DATA
var team = ""

var thirdPersonEnabled : bool = false
@onready var thirdPersonAnimPlayer : AnimationPlayer = $ThirdPersonCameraAnim

func _enter_tree():
	set_multiplayer_authority(name.to_int())

func _ready():
	#modificar dependiendo del arma que tenga el jugador
	#si no es el que controla al player
	
	if not is_multiplayer_authority(): 
		arms.visible = false
		camera.current = false
		thirdPersonCam.current = false
		return
	
	player_body.visible = false
	initialHead_pos = eyes.position.y
	initialHands_pos = arms.position.y
	hud.animationPlayer.play("swap_gun")
	camera.current = true
	hud.grenadeCountLabel.text = str("x" , arms.grenadeQuantity)

func _input(event : InputEvent):
	if not is_multiplayer_authority():
		return
		
	#if Input.is_action_just_pressed("noHUD"):
		#hud.visible = false
		#Network.game.killFeedVBox.visible = false
		#Network.game.ChatMessagesDisplay.visible = false
		#Network.game.chatText.visible = false
	
	#If mouse is moving
	if event is InputEventMouseMotion:
		#rotate player x axis ONLY
		
		if Input.is_action_pressed("ADS"):
			rotate_y(deg_to_rad(-event.relative.x * GlobalData.configData.get_value("Controls", "AimMouseSensibility", 1.0)))
			#rotate camera y axis and limit its rotation
			eyes.rotate_x(deg_to_rad(-event.relative.y * GlobalData.configData.get_value("Controls", "AimMouseSensibility", 1.0)))
		else:
			rotate_y(deg_to_rad(-event.relative.x * GlobalData.configData.get_value("Controls", "MouseSensibility", 1.0)))
			#rotate camera y axis and limit its rotation
			eyes.rotate_x(deg_to_rad(-event.relative.y * GlobalData.configData.get_value("Controls", "MouseSensibility", 1.0)))
		eyes.rotation.x = clamp(eyes.rotation.x, deg_to_rad(-50), deg_to_rad(50))
		
	
	if Input.is_action_just_pressed("Pause") and isPauseMenuOpened:
		if pauseMenu.optionsMainContainer.visible:
			pauseMenu.optionsMainContainer.animationPlayer.play("OpenOptions", -1, -2, true)
			await pauseMenu.optionsMainContainer.animationPlayer.animation_finished
			pauseMenu.optionsMainContainer.hide()
		pauseMenu.animationPlayer.play("OpenMenu", -1, -2, true)
		
		if Input.mouse_mode != Input.MOUSE_MODE_CONFINED:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
		await pauseMenu.animationPlayer.animation_finished
		isPauseMenuOpened = false
		pauseMenu.hide()
		state_machine.process_mode = PROCESS_MODE_INHERIT
	
	if Input.is_action_just_pressed("Pause") and not isPauseMenuOpened:
		if arms.weaponHolder.get_child_count() <= 0 or weaponSelectionMenu.visible:
			return
		
		pauseMenu.animationPlayer.play("OpenMenu", -1, 2, false)
		pauseMenu.show()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
		await pauseMenu.animationPlayer.animation_finished
		isPauseMenuOpened = true

#-----------------------------------------------Changing between perspective---------------------------------------------
	if Network.gameData.get("perspective") == "FIRST PERSON ONLY":
		return
	if Input.is_action_just_pressed("Perspective") and not Input.is_action_pressed("ADS"):
		if camera.current:
			camera.current = false
			thirdPersonCam.current = true
			arms.weaponHolder.visible = false
			arms.grenade.visible = false
			player_body.visible = true
			thirdPersonEnabled = true
			
		elif thirdPersonCam.current:
			
			camera.current = true
			thirdPersonCam.current = false
			if not arms.grenade.animPlayer.is_playing():
				arms.weaponHolder.visible = true
			player_body.visible = false
			thirdPersonEnabled = false
			arms.grenade.visible = true
	
	if Input.is_action_just_pressed("ADS") and camera.current == false:
		camera.current = true
		thirdPersonCam.current = false
		if not arms.grenade.animPlayer.is_playing():
			arms.weaponHolder.visible = true
		arms.grenade.visible = true
		player_body.visible = false
		thirdPersonEnabled = true
		
	
	if Input.is_action_just_released("ADS") and thirdPersonEnabled:
		arms.grenade.visible = false
		camera.current = false
		thirdPersonCam.current = true
		arms.weaponHolder.visible = false
		player_body.visible = true

func _process(delta: float) -> void:
	if camera.shakeStrength >0:
		camera.shakeStrength = lerpf(camera.shakeStrength, 0, camera.shakeFade * delta)
		
		var shakeOffset : Vector2 = camera.randomizeCamOffset()
		camera.h_offset = shakeOffset.x
		camera.v_offset = shakeOffset.y

func _physics_process(delta):
	if not is_multiplayer_authority():
		return
	
	if health < 0:
		velocity = Vector3.ZERO
	
	if health < 35 and not is_dead:
		hud.HurtScreenAnimationPlayer.play("low_hp")
	else:
		hud.HurtScreenAnimationPlayer.stop()
	
	hud.healthBar.value = health
	
	if health < 100 and can_heal:
		updateHealth.rpc(multiplayer.get_unique_id())
	
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
	
	if Network.game.chatText.has_focus() or isPauseMenuOpened:
		input_direction = Vector2.ZERO
	
	if is_on_floor() and input_direction != Vector2.ZERO:
		direction = lerp(direction, transform.basis * Vector3(input_direction.x, 0, input_direction.y).normalized(), delta * lerp_speed)
		headBobbing_vector.y =  sin(headBobbing_index)
		headBobbing_vector.x =  sin(headBobbing_index/2)+0.5
		
		eyes.position.y = lerp(eyes.position.y, headBobbing_vector.y * (headBobbing_curr_intensity / 2.0) * 4, delta * lerp_speed)
		eyes.position.x = lerp(eyes.position.x, headBobbing_vector.x * headBobbing_curr_intensity, delta * lerp_speed)
		
		arms.position.y = lerp(arms.position.y, headBobbing_vector.y * (headBobbing_curr_intensity / 2.0), delta * lerp_speed)
		arms.position.x = lerp(arms.position.x, headBobbing_vector.x * headBobbing_curr_intensity, delta * lerp_speed)
	
	elif is_on_floor() and input_direction == Vector2.ZERO:
		
		direction = lerp(direction, transform.basis * Vector3(input_direction.x, 0, input_direction.y).normalized(), delta * lerp_air_speed)
		eyes.position.y = lerp(eyes.position.y, 0.0, delta * lerp_speed)
		eyes.position.x = lerp(eyes.position.x, 0.0, delta * lerp_speed)
		
		arms.position.y = lerp(arms.position.y, 0.0, delta * lerp_speed)
		arms.position.x = lerp(arms.position.x, 0.0, delta * lerp_speed)
	
	_checkCollisionWithWall()

#leaning ---------------------- WIP
	#leaning(delta)
	move_and_slide()

func _on_state_machine_transitioned(state_name, _old_state):
	state = state_name
	#print("Last state: " , _old_state , "   ---   New state: " , state_name)

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
			lerpHandsPosition = 0
			

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
func assign_enemy_to_player_hit(instigator_player_id, affected_player_id, damageType = "Bullet"):
	can_heal = false
	if animationPlayer.is_playing():
		animationPlayer.play("RESET")
	animationPlayer.play("hit")
	
	if damageType == "Grenade":
		hud.HurtScreenAnimationPlayer.play("low_hp", -1, 2.0, false)
		
		await get_tree().create_timer(2).timeout
		if health > 0:
			can_heal = true
	
	if damageType != "Grenade":
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
				if health > 0:
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
func updateHealth(identifier):
	for p : Player in Network.game.players_node.get_children():
		if p.name == str(identifier):
			p.health += 0.05


#hacer RPC al jugador que va a morir para transicionarlo a muerto y luego otro rpc para transicionarlo a vivo (la state machine)
@rpc("any_peer", "call_local", "reliable")
func die_respawn(player_id, instigator_id, deathType = "weapon"):
	var killerName = ""
	var deadName = ""
	var killerWeaponImage : CompressedTexture2D
	if Network.game == null:
		return
		
	if not visible:
		return
	
	for index in Network.game.players.size():
		var playerDict = Network.game.players[index]
		if playerDict["id"] == str(instigator_id):
			if instigator_id != player_id:
				playerDict["score"] += 100
				playerDict["kills"] += 1
			
			if deathType == "weapon":
				killerName = Steam.getFriendPersonaName(Network.peer.get_steam64_from_peer_id(int(playerDict["id"])))
				killerWeaponImage = Network.game.players_node.get_child(index).arms.actualWeapon.weaponData.weaponImage
			elif deathType == "grenade":
				killerName = Steam.getFriendPersonaName(Network.peer.get_steam64_from_peer_id(int(playerDict["id"])))
				var nadeTexture : CompressedTexture2D = CompressedTexture2D.new()
				nadeTexture = load("res://GameResources/Textures/Grenades/grenade_icon.png")
				killerWeaponImage = nadeTexture
		
		if playerDict["id"] == str(player_id):
			playerDict["deaths"] += 1
			if instigator_id != player_id:
				deadName = Steam.getFriendPersonaName(Network.peer.get_steam64_from_peer_id(int(playerDict["id"])))
				
	Network.game.dashboardMatch.get_lobby_data()
	Network.game.add_kill_to_killFeed(killerName, killerWeaponImage, deadName)
	visible = false
	if player_id == multiplayer.get_unique_id():
		hud.visible = false
		thirdPersonCam.current = true
		arms.visible = false
		state_machine.process_mode = Node.PROCESS_MODE_DISABLED
		for weapon : Weapon in arms.weaponHolder.get_children():
			weapon.being_used = false
		
	set_collision_mask_value(3, false)
	Network.game.death_count += 1
	
	#get the dead player to access its weapon
	var player : Player = null
	for p : Player in Network.game.players_node.get_children():
		if p.name.to_int() == player_id:
			player = p

	var deathModelScene = death_model.instantiate()
	deathModelScene.name = "body_count" + str(Network.game.death_count)
	#setear skin al cuerpo muerto
	var playerbodySkin = player_body.playerMesh.get_active_material(0).get_shader_parameter("albedo")
	var playerheadSkin = player_body.playerMesh.get_active_material(1).get_shader_parameter("albedo")
	
	for audio in player.player_sounds.get_children():
			player.player_sounds.remove_child(audio)
			
	Network.game.add_child(deathModelScene)
	deathModelScene.playerMesh.get_active_material(0).set_shader_parameter("albedo", playerbodySkin)
	deathModelScene.playerMesh.get_active_material(1).set_shader_parameter("albedo", playerheadSkin)
	deathModelScene.parent.rotation_degrees = rotation_degrees
	deathModelScene.position = position
	deathModelScene.position.y -= player_body.scale.y * 1.5
	deathModelScene.scale = Vector3(0.5, 0.5, 0.5)
	deathModelScene.rigidBody.add_collision_exception_with(self)
		
	var weaponPickupScene = load(player.arms.actualWeapon.weaponData.weaponPickupScene)
	var weaponPickupNode : WeaponInteractable = weaponPickupScene.instantiate()
	weaponPickupNode.id = randi()
	weaponPickupNode.position = deathModelScene.position
	weaponPickupNode.weaponData.reserveAmmo = player.arms.actualWeapon.weaponData.reserveAmmo
	weaponPickupNode.weaponData.bulletsInMag = player.arms.actualWeapon.weaponData.bulletsInMag
	Network.game.interactables_node.add_child(weaponPickupNode)
	
	player.can_heal = false
	player.is_dead = true
	
	await deathModelScene.animationPlayer.animation_finished
	
	set_collision_mask_value(3, true)
	
	#hay que hacer que el que ha muerto sincronice y le diga al resto que sea visible el player, porque si no al resto les saldrá visible antes
	if player_id == multiplayer.get_unique_id():
		global_position = Network.game.random_spawn()
		camera.current = true
		
		await get_tree().create_timer(0.1).timeout
		
		hud.animationPlayer.play("swap_gun")
		hud.visible = true
		arms.visible = true
		player_body.visible = false
		thirdPersonEnabled = false
		arms.weaponHolder.visible = true
		arms.grenadeQuantity = 1
		hud.grenadeCountLabel.text = "x1"
		arms.state_machine.transition_to("Idle")
		state_machine.process_mode = Node.PROCESS_MODE_INHERIT
		
		for index in Network.game.players.size():
			if Network.game.players[index]["id"] == player.name:
				var playerData : Dictionary = Network.game.players[index]
				playerData.erase("secondaryWeaponName")
				playerData.erase("secondaryWeaponPath")
				Network.updatePlayerWeapon.rpc(Network.game.players[index]["id"], Network.game.players[index]["classSelectedPath"])
				
		#make_player_visible.rpc(player_id)


@rpc("any_peer", "call_local", "reliable")
func make_player_visible(player_id):
	for p : Player in Network.game.players_node.get_children():
		if p.name.to_int() == player_id:
			p.visible = true

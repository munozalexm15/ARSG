class_name Arms
extends Node3D

signal playerSwappingWeapons

@export var animationNode := NodePath()
@onready var animationPlayer : AnimationPlayer = get_node(animationNode)

@export var rayNode := NodePath()
@onready var interactorRay : RayCast3D = get_node(rayNode)

@export var cameraNode := NodePath()
@onready var camera : Camera3D = get_node(cameraNode)

@export var playerNode := NodePath()
@onready var player : Player = get_node(playerNode)

@export var initial_position : Vector3
@export var ads_position : Vector3
var ads_lerp = 20
var fovList = {"Default": 75.0, "ADS": 50.0, "Sniper": 25.0}

@onready var weaponHolder = $WeaponHolder
@onready var reloadTimer : Timer = $ReloadTimer
@onready var state_machine: StateMachine = $StateMachine
@onready var flashlight : SpotLight3D = $Flashlight
@onready var knife : Node3D = $Knife

var actual_weapon_index = 0
var actualWeapon
var actual_animation = ""
var meleeAttack = false

var cam_rotation_amount : float = 0.025
var weapon_rotation_amount : float = 0.01
var weapon_sway_amount : float = 5
var invert_weapon_sway : bool = false

var mouse_input : Vector2

var default_weaponHolder_pos = Vector3(Vector3.ZERO)

# Called when the node enters the scene tree for the first time.
func _ready():
	if not is_multiplayer_authority():
		return
	knife.set_process(false)
	interactorRay.add_exception(owner)
	weaponHolder.get_child(actual_weapon_index).visible = true
	weaponHolder.get_child(actual_weapon_index).being_used = true
	default_weaponHolder_pos = weaponHolder.position
	
	actualWeapon = weaponHolder.get_child(actual_weapon_index)
	playerSwappingWeapons.emit()
	
	reloadTimer.wait_time = actualWeapon.weaponData.reloadTime
	for weapon in weaponHolder.get_children():
		weapon.position = weapon.weaponData.weaponSpawnPosition

func _input(event):
	if not is_multiplayer_authority():
		return
		
	if event is InputEventMouseMotion:
		mouse_input = event.relative
	
func _physics_process(delta):
	if not is_multiplayer_authority():
		return
	
	if Input.is_action_just_pressed("Flashlight"):
		flashlight.visible = !flashlight.visible

	player.hud.primaryWeaponIcon.texture = weaponHolder.get_child(0).weaponData.weaponImage
	player.hud.secondaryWeaponIcon.texture = weaponHolder.get_child(1).weaponData.weaponImage
	
	player.hud.weaponFireMode.text = actualWeapon.weaponData.selectedFireMode
	
	player.hud.weaponCaliber.text = actualWeapon.weaponData.weaponCaliber
	player.hud.ammoCounter.text = str(actualWeapon.weaponData.bulletsInMag) + " / " + str(actualWeapon.weaponData.reserveAmmo)
	
	if Input.is_action_pressed("ADS"):
		if actualWeapon.weaponData.weaponType == "Sniper":
			weaponHolder.transform.origin = weaponHolder.transform.origin.lerp(ads_position, ads_lerp * delta)
			camera.fov = lerp(camera.fov, fovList["Sniper"], ads_lerp * delta)
		else:
			weaponHolder.transform.origin = weaponHolder.transform.origin.lerp(ads_position, ads_lerp * delta)
			camera.fov = lerp(camera.fov, fovList["ADS"], ads_lerp * delta)
	else:
		weaponHolder.transform.origin = weaponHolder.transform.origin.lerp(initial_position, ads_lerp * delta)
		camera.fov = lerp(camera.fov, fovList["Default"], ads_lerp * delta)
	
	if Input.is_action_just_pressed("ADS") and actualWeapon.weaponData.weaponType == "Sniper":
		player.hud.aimAnimationPlayer.play("Aim")
	
	if Input.is_action_just_released("ADS") and actualWeapon.weaponData.weaponType == "Sniper":
			player.hud.aimAnimationPlayer.play("Aim", -1, -1, true)

#MELEE MECHANIC ------------ WIP
	#if Input.is_action_just_pressed("Melee") and state_machine.state.name != "Melee":
		#knife.set_process(true)
		#animationPlayer.play("ShowKnife")
		#state_machine.transition_to("Melee")
	
	cam_tilt(player.input_direction.x, delta)
	weapon_tilt(player.input_direction.x, delta)
	weapon_sway(delta)
	
func cam_tilt(input_x, delta):
	if player.camera:
		player.camera.rotation.z = lerp(player.camera.rotation.z, -input_x * cam_rotation_amount, 10 * delta)

func weapon_tilt(input_x, delta):
	if weaponHolder:
		weaponHolder.rotation.y = lerp(weaponHolder.rotation.y, -input_x * weapon_rotation_amount * 10, 10 * delta)

func weapon_sway(delta):
	mouse_input = lerp(mouse_input,Vector2.ZERO,10*delta)
	weaponHolder.rotation.x = lerp(weaponHolder.rotation.x, mouse_input.y * weapon_rotation_amount * (-1 if invert_weapon_sway else 1), 10 * delta)
	weaponHolder.rotation.y = lerp(weaponHolder.rotation.y, mouse_input.x * weapon_rotation_amount * (-1 if invert_weapon_sway else 1), 10 * delta)	

func _on_interact_ray_swap_weapon(pickupWeapon, isSwapping):
	state_machine.transition_to("Idle", {"replace_weapon" = pickupWeapon, "isSwappingValue" = isSwapping})

func _on_interact_ray_pickup_ammo(ammoBox : RigidBody3D):
	for x in weaponHolder.get_child_count():
		if weaponHolder.get_child(x).weaponData.weaponType == ammoBox.ammoData.ammoType and weaponHolder.get_child(x).weaponData.reserveAmmo < weaponHolder.get_child(x).weaponData.magSize * 4:
			weaponHolder.get_child(x).weaponData.reserveAmmo += ammoBox.ammoData.resupplyQuantity
			ammoBox.ammoData.numberUses -= 1
			if ammoBox.ammoData.numberUses == 0:
				
				ammoBox.queue_free()

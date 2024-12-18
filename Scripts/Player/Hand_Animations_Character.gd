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
@onready var knife : Knife = $Knife

var actual_weapon_index = 0
var actualWeapon : Weapon
var actual_animation = ""
var meleeAttack = false

#GRENADE
@onready var grenade : Grenade = $GrenadeHands
var readyToThrow = false
var grenadeQuantity : int = 1

var cam_rotation_amount : float = 0.025
var weapon_rotation_amount : float = 0.01
var weapon_sway_amount : float = 5
var invert_weapon_sway : bool = false

var mouse_input : Vector2

var default_weaponHolder_pos = Vector3(Vector3.ZERO)

var handsAssignedTexture : Texture = null

# Called when the node enters the scene tree for the first time.
func _ready():
	if not is_multiplayer_authority():
		if weaponHolder.get_child_count() > 0:
			actualWeapon = weaponHolder.get_child(actual_weapon_index)
		grenade.visible = false
		return 
		
	knife.set_process(false) 
	knife.knifeRigidBody.add_collision_exception_with(player)
	interactorRay.add_exception(owner)
	default_weaponHolder_pos = weaponHolder.position
	playerSwappingWeapons.emit()

func _input(event):
	if not is_multiplayer_authority():
		return
		
	if event is InputEventMouseMotion:
		mouse_input = event.relative
	
func _physics_process(delta):
	if not is_multiplayer_authority():
		return
	#if Input.is_action_just_pressed("Flashlight"):
		#return
		#flashlight.visible = !flashlight.visible
	
	if weaponHolder.get_child_count() == 0:
		return
	
	player.hud.primaryWeaponIcon.texture = weaponHolder.get_child(0).weaponData.weaponImage
	if weaponHolder.get_child_count() > 1:
		player.hud.secondaryWeaponIcon.texture = weaponHolder.get_child(1).weaponData.weaponImage
	
	player.hud.weaponFireMode.text = actualWeapon.weaponData.selectedFireMode
	
	player.hud.weaponCaliber.text = actualWeapon.weaponData.weaponCaliber
	player.hud.ammoCounter.text = str(actualWeapon.weaponData.bulletsInMag) + " / " + str(actualWeapon.weaponData.reserveAmmo)
	
	if Input.is_action_pressed("Grenade") and readyToThrow == false and state_machine.state.name != "Grenade" and grenadeQuantity > 0 and player.health > 0 and not player.isPauseMenuOpened:
		grenade.leftHand.get_active_material(0).albedo_texture = player.arms.handsAssignedTexture
		grenade.rightHand.get_active_material(0).albedo_texture= player.arms.handsAssignedTexture
		state_machine.transition_to("Grenade")
	
	if Input.is_action_pressed("ADS") and state_machine.state.name != "Reload":
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
	#if Input.is_action_just_pressed("Melee") and (state_machine.state.name != "Melee" or state_machine.state.name != "Grende"):
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
		weaponHolder.position.x = lerp(weaponHolder.position.x, (player.input_direction.y * 3) * weapon_rotation_amount * 10, 5 * delta)

func weapon_sway(delta):
	mouse_input = lerp(mouse_input,Vector2.ZERO,10*delta)
	weaponHolder.rotation.x = lerp(weaponHolder.rotation.x, mouse_input.y * weapon_rotation_amount * (-1 if invert_weapon_sway else 1), 10 * delta)
	weaponHolder.rotation.y = lerp(weaponHolder.rotation.y, mouse_input.x * weapon_rotation_amount * (-1 if invert_weapon_sway else 1), 10 * delta)	


func _on_interact_ray_swap_weapon(actualWeaponName, pickupWeaponScene : String, isSwapping : bool):
	drop_weapon.rpc(actualWeaponName, pickupWeaponScene, isSwapping)

@rpc("any_peer", "call_local", "reliable")
func on_grenade_throw(pID):
	var p : Player = Network.findPlayer(pID)
	if p == null:
		return
	
	

@rpc("authority", "call_local", "reliable")
func drop_weapon(actualWeaponName, pickupWeaponScene, _isSwapping):
	
	var weapon_Ref = null
	for x in weaponHolder.get_child_count():
		if weaponHolder.get_child(x).weaponData.name == actualWeaponName:
			weapon_Ref = weaponHolder.get_child(x)
	
	if weapon_Ref == null:
		return
	
	var weapon_to_spawn = load(weapon_Ref.weaponData.weaponPickupScene)
	var droppedWeapon : WeaponInteractable = weapon_to_spawn.instantiate()
	
	droppedWeapon.weaponData.reserveAmmo = weapon_Ref.weaponData.reserveAmmo
	droppedWeapon.weaponData.bulletsInMag = weapon_Ref.weaponData.bulletsInMag

	#if both weapons have the same caliber, when dropping the actual weapon it will lose all its reserve ammo 
	if weaponHolder.get_child_count() != 1:
		if weaponHolder.get_child(0).weaponData.weaponCaliber == weaponHolder.get_child(1).weaponData.weaponCaliber:
			droppedWeapon.weaponData.reserveAmmo = 0
	
		droppedWeapon.isAlreadyGrabbed = true
		droppedWeapon.set_global_transform(weaponHolder.get_global_transform())
		Network.game.interactables_node.add_child(droppedWeapon)
	
	if weaponHolder.get_child_count() != 1:
		weaponHolder.remove_child(weapon_Ref)
	
	actual_weapon_index = 0
	actualWeapon = weaponHolder.get_child(actual_weapon_index)
	
	player.eyes.get_child(0).setRecoil(actualWeapon.weaponData.recoil)
	
	for audio in player.player_sounds.get_children():
		player.player_sounds.remove_child(audio)
	
	#weapon switching
	var spawnedWeaponScene = load(pickupWeaponScene)
	var newWeapon : Weapon = spawnedWeaponScene.instantiate()
	newWeapon.set_multiplayer_authority(get_multiplayer_authority())
	newWeapon.position = newWeapon.weaponData.weaponSpawnPosition
	newWeapon.handsNode = get_path()
	
	weaponHolder.add_child(newWeapon)
	
	#as it is swapping weapons on pickup, set the current weapon to not being used
	actual_weapon_index = 1
	loadWeapon(actual_weapon_index)
	actualWeapon = weaponHolder.get_child(actual_weapon_index)
	
	player.eyes.get_child(0).setRecoil(actualWeapon.weaponData.recoil)
	
	var playerWeaponDict : Dictionary = { "id" =  str(player.name) }
	playerWeaponDict["actualWeaponName"] = actualWeapon.weaponData.name
	playerWeaponDict["actualWeaponPath"] = actualWeapon.weaponData.weaponScene
	
	playerWeaponDict["primaryWeaponName"] = weaponHolder.get_child(0).weaponData.name
	playerWeaponDict["primaryWeaponPath"] = weaponHolder.get_child(0).weaponData.weaponScene
	
	if weaponHolder.get_child_count() > 1:
		playerWeaponDict["secondaryWeaponName"] = weaponHolder.get_child(1).weaponData.name
		playerWeaponDict["secondaryWeaponPath"] = weaponHolder.get_child(1).weaponData.weaponScene
	
	#if both weapons have the same caliber, add more ammo to both reserve
	if actualWeapon.weaponData.weaponCaliber == weaponHolder.get_child(0).weaponData.weaponCaliber:
		weaponHolder.get_child(1).weaponData.reserveAmmo = weaponHolder.get_child(0).weaponData.reserveAmmo
		weaponHolder.get_child(0).weaponData.reserveAmmo = weaponHolder.get_child(1).weaponData.reserveAmmo
	
	state_machine.transition_to("SwappingWeapon")

@rpc("any_peer", "call_local", "reliable")
func updatePlayerWeaponStatus(playerDict : Dictionary):
	for index in Network.game.players.size():
		var playerData = Network.game.players[index]
		
		if playerData["id"] == playerDict["id"]:
			playerData["actualWeaponName"] = playerDict["actualWeaponName"]
			playerData["actualWeaponPath"] = playerDict["actualWeaponPath"]
			
			playerData["primaryWeaponName"] = playerDict["primaryWeaponName"]
			playerData["primaryWeaponPath"] = playerDict["primaryWeaponPath"]
			
			if playerDict.has("secondaryWeaponName"):
				playerData["secondaryWeaponName"] = playerDict["secondaryWeaponName"]
				playerData["secondaryWeaponPath"] = playerDict["secondaryWeaponPath"]

func loadWeapon(index):
	for x in weaponHolder.get_child_count():
		weaponHolder.get_child(x).being_used = false
		weaponHolder.get_child(x).visible = false

	weaponHolder.get_child(index).being_used = true
	weaponHolder.get_child(index).visible = true

func _on_interact_ray_pickup_ammo(ammoBox : RigidBody3D):
	for x in weaponHolder.get_child_count():
		if weaponHolder.get_child(x).weaponData.weaponType == ammoBox.ammoData.ammoType and weaponHolder.get_child(x).weaponData.reserveAmmo < weaponHolder.get_child(x).weaponData.magSize * 4:
			weaponHolder.get_child(x).weaponData.reserveAmmo += ammoBox.ammoData.resupplyQuantity
			ammoBox.ammoData.numberUses -= 1
			if ammoBox.ammoData.numberUses == 0:
				
				ammoBox.queue_free()


func _on_state_machine_transitioned(_state_name, _old_state):
	pass

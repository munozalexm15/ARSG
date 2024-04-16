extends Node3D

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
var fovList = {"Default": 75.0, "ADS": 50.0}

@onready var weaponHolder = $WeaponHolder
@onready var reloadTimer : Timer = $ReloadTimer

var actual_weapon_index = 0
var actualWeapon
var actual_animation = ""
var isSwappingWeapon = false
var isReloading = false


var cam_rotation_amount : float = 0.01
var weapon_rotation_amount : float = 0.01
var weapon_sway_amount : float = 5
var invert_weapon_sway : bool = false

var mouse_input : Vector2

var default_weaponHolder_pos = Vector3(Vector3.ZERO)

# Called when the node enters the scene tree for the first time.
func _ready():
	interactorRay.add_exception(owner)
	weaponHolder.get_child(actual_weapon_index).visible = true
	animationPlayer.play("Idle")
	default_weaponHolder_pos = weaponHolder.position
	actualWeapon = weaponHolder.get_child(actual_weapon_index)
	reloadTimer.wait_time = actualWeapon.weaponData.reloadTime
	loadWeapon(actual_weapon_index)

func _input(event):
	if event is InputEventMouseMotion:
		mouse_input = event.relative
	
	if weaponHolder.get_child_count() > 1:
		swap_weapon()
		mouse_swap_weapon_logic()
	
func _physics_process(delta):
	
	if Input.is_action_pressed("Reload") and actualWeapon.weaponData.bulletsInMag < actualWeapon.weaponData.magSize and actualWeapon.weaponData.reserveAmmo > 0 and not isReloading:
		animationPlayer.play("Reload")
		isReloading = true
	
	player.hud.weaponFireMode.text = "Auto" if actualWeapon.weaponData.isAutomatic else "Semi"
	player.hud.weaponName.text = actualWeapon.weaponData.name
	player.hud.weaponCaliber.text = actualWeapon.weaponData.weaponCaliber
	player.hud.ammoCounter.text = str(actualWeapon.weaponData.bulletsInMag) + " / " + str(actualWeapon.weaponData.reserveAmmo)
	#cam_tilt(player.input_direction.x, delta)
	weapon_tilt(player.input_direction.x, delta)
	weapon_sway(delta)
	reload_listener()
		
	if Input.is_action_pressed("ADS") and not isReloading:
		weaponHolder.transform.origin = weaponHolder.transform.origin.lerp(ads_position, ads_lerp * delta)
		camera.fov = lerp(camera.fov, fovList["ADS"], ads_lerp * delta)
	else:
		weaponHolder.transform.origin = weaponHolder.transform.origin.lerp(initial_position, ads_lerp * delta)
		camera.fov = lerp(camera.fov, fovList["Default"], ads_lerp * delta)
	
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

func mouse_swap_weapon_logic():
	if Input.is_action_just_pressed("Next Weapon") and not isSwappingWeapon:
		isSwappingWeapon = true
		if actual_weapon_index < weaponHolder.get_child_count() -1:
			actual_weapon_index += 1
		else:
			actual_weapon_index = 0
		player.eyes.get_child(0).setRecoil(actualWeapon.weaponData.recoil)
		
		animationPlayer.play("SwapWeapon")
		
	if Input.is_action_just_pressed("Previous Weapon") and not isSwappingWeapon:
		isSwappingWeapon = true
		if actual_weapon_index >= 0:
			actual_weapon_index -= 1
		else:
			actual_weapon_index = get_child_count() -1
			
		player.eyes.get_child(0).setRecoil(actualWeapon.weaponData.recoil)
		animationPlayer.play("SwapWeapon")
	
func swap_weapon():
	if Input.is_action_just_pressed("Primary weapon") and not isSwappingWeapon:
		if actual_weapon_index != 0:
			isSwappingWeapon = true
			actual_weapon_index = 0
			player.eyes.get_child(0).setRecoil(actualWeapon.weaponData.recoil)
			animationPlayer.play("SwapWeapon")
		
	if Input.is_action_just_pressed("Secondary weapon") and not isSwappingWeapon:
		if actual_weapon_index != 1:
			isSwappingWeapon = true
			actual_weapon_index = 1
			player.eyes.get_child(0).setRecoil(actualWeapon.weaponData.recoil)
			animationPlayer.play("SwapWeapon")

func loadWeapon(index):
	for x in weaponHolder.get_child_count():
		weaponHolder.get_child(x).process_mode = Node.PROCESS_MODE_DISABLED
		weaponHolder.get_child(x).visible = false
	weaponHolder.get_child(index).process_mode = Node.PROCESS_MODE_ALWAYS
	weaponHolder.get_child(index).visible = true

func _on_animation_player_animation_finished(anim_name):
	if (anim_name == "Reload"):
		reloadTimer.start()
	
	if (anim_name == "SwapWeapon"):
		loadWeapon(actual_weapon_index)
		actualWeapon = weaponHolder.get_child(actual_weapon_index)
		reloadTimer.wait_time = actualWeapon.weaponData.reloadTime
		
		isSwappingWeapon = false
		if player.state != "Run" and not isReloading:
			animationPlayer.play("Idle")
		elif player.state == "Run" and not isReloading:
			animationPlayer.play("Run")

func reload_listener():
	if actualWeapon.weaponData.bulletsInMag <= 0 and actualWeapon.weaponData.reserveAmmo > 0 and not isReloading:
		animationPlayer.play("Reload")
		isReloading = true

func _on_animation_player_animation_started(anim_name):
	#cancel weapon switching if player runs, crouch, etc.
	if (anim_name == "Run" or anim_name == "Idle") and isSwappingWeapon:
		if actual_weapon_index == 0:
			actual_weapon_index = 1
		else:
			actual_weapon_index = 0
		isSwappingWeapon = false
		
	if anim_name != "Reload" and isReloading:
		isReloading = false
		reloadTimer.stop()

func drop_weapon(name):
	var weapon_Ref = null
	for x in weaponHolder.get_child_count():
		if weaponHolder.get_child(x).weaponData.name == name:
			weapon_Ref = weaponHolder.get_child(x)
	
	if weapon_Ref != null:
		var weapon_to_spawn = load(weapon_Ref.weaponData.weaponPickupScene)
		var spawnedWeapon = weapon_to_spawn.instantiate()
		spawnedWeapon.weaponData.reserveAmmo = weapon_Ref.weaponData.reserveAmmo
		spawnedWeapon.weaponData.bulletsInMag = weapon_Ref.weaponData.bulletsInMag
		print(spawnedWeapon.weaponData.bulletsInMag)
		spawnedWeapon.set_global_transform(weaponHolder.get_global_transform())
		var world = get_tree().get_root().get_child(0)
		world.add_child(spawnedWeapon)
		weaponHolder.remove_child(weapon_Ref)
		
		isSwappingWeapon = true
		actual_weapon_index = 0
		actualWeapon = weaponHolder.get_child(actual_weapon_index)
		player.eyes.get_child(0).setRecoil(actualWeapon.weaponData.recoil)
		animationPlayer.play("SwapWeapon")


func _on_reload_timer_timeout():
	reloadTimer.stop()
	reloadTimer.wait_time = actualWeapon.weaponData.reloadTime
	var ammoLeft = actualWeapon.weaponData.bulletsInMag
	if isReloading == true:
		isReloading = false
		isSwappingWeapon = false
		
		#Check reserve ammo is greater than the required amount
		if (actualWeapon.weaponData.magSize - ammoLeft) <= actualWeapon.weaponData.reserveAmmo:
			actualWeapon.weaponData.reserveAmmo -= actualWeapon.weaponData.magSize - ammoLeft
			actualWeapon.weaponData.bulletsInMag += actualWeapon.weaponData.magSize - ammoLeft
			
			#If both weapons share the same caliber, subtract to both weapons the reserve ammo
			for x in weaponHolder.get_child_count():
				if weaponHolder.get_child(x) != actualWeapon and weaponHolder.get_child(x).weaponData.weaponCaliber == actualWeapon.weaponData.weaponCaliber:
					weaponHolder.get_child(x).weaponData.reserveAmmo -=  actualWeapon.weaponData.magSize - ammoLeft
	
		#if not, give the remaining reserve ammo to the mag
		else:
			actualWeapon.weaponData.bulletsInMag += actualWeapon.weaponData.reserveAmmo
			actualWeapon.weaponData.reserveAmmo = 0
	
		if player.state != "Run":
			animationPlayer.play("Idle")
		if player.state == "Run":
			animationPlayer.play("Run")


func _on_interact_ray_swap_weapon(body):
	if body.isPickupReady:
		var weapon_equipped = null
		for x in weaponHolder.get_child_count():
			if weaponHolder.get_child(x).weaponData.name == body.weaponData.name:
				weaponHolder.get_child(x).name = body.weaponData.name
				weapon_equipped = weaponHolder.get_child(x)
		
		if not weapon_equipped and weaponHolder.get_child_count() == 2:
			drop_weapon(actualWeapon.weaponData.name)
		
		if weapon_equipped:
			var randomMagAmmo = randf_range(0, body.weaponData.magSize)
			
			#Give ammo to the other weapon reserve - RANDOMIZED, else: body.weaponData.bulletsInMag
			for x in weaponHolder.get_child_count():
				if weaponHolder.get_child(x) != weapon_equipped and weaponHolder.get_child(x).weaponData.weaponCaliber == weapon_equipped.weaponData.weaponCaliber:
					weaponHolder.get_child(x).weaponData.reserveAmmo += randomMagAmmo
			weapon_equipped.weaponData.reserveAmmo += randomMagAmmo
			body.queue_free()
		
		elif not weapon_equipped and weaponHolder.get_child_count() < 2:
			var spawnedWeaponScene = load(body.weaponData.weaponScene)
			var spawnedWeapon = spawnedWeaponScene.instantiate()
			spawnedWeapon.position = body.weaponData.weaponSpawnPosition
			spawnedWeapon.handsNode = self.get_path()
			weaponHolder.add_child(spawnedWeapon)
			body.queue_free()
			
			isSwappingWeapon = true
			actual_weapon_index = 1
			loadWeapon(actual_weapon_index)
			actualWeapon = weaponHolder.get_child(actual_weapon_index)
			
			#Give ammo to the other weapon reserve - RANDOMIZED, else: body.weaponData.bulletsInMag
			var randomMagAmmo = randf_range(0, body.weaponData.magSize)
			actualWeapon.weaponData.bulletsInMag = randomMagAmmo
			player.eyes.get_child(0).setRecoil(actualWeapon.weaponData.recoil)
			animationPlayer.play("SwapWeapon")

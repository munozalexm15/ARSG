class_name Weapon
extends Node3D

@export var weaponData : WeaponData

@onready var fire_sound : AudioStreamPlayer3D = $ASP_ShotShound
@onready var reload_sound : AudioStreamPlayer3D = $ASP_ReloadSound


@export var handsNode := NodePath()
@onready var hands : Arms = get_node(handsNode)

@onready var animPlayer = $AnimationPlayer
@onready var handsAnimPlayer = $Player_Arms/AnimationPlayer

#idle weapon sway variables
@export var sway_noise : NoiseTexture2D
@export var sway_speed : float = 1.2

var random_sway_x
var random_sway_y
var random_sway_amount : float
var idle_sway_adjustment
var idle_sway_rotation_strength
var time : float = 0

#Weapon parts
@onready var muzzle = $Muzzle
@onready var muzzleSmoke : Trail3D = $Muzzle/MuzzleSmoke
@export var bullet_type: PackedScene
@onready var bullet_case_particles : CPUParticles3D = $Bullet_Case_Particles
@onready var muzzle_flash_particles :CPUParticles3D = $Muzzle/MuzzleFlash
@onready var muzzle_flash_light : OmniLight3D = $Muzzle/MuzzleFlashLight
@onready var fire_selection_sound : AudioStreamPlayer3D = $ASP_FireSelectionSound
@onready var no_ammo_sound : AudioStreamPlayer3D = $ASP_NoAmmoSound
var time_to_shoot = 0

#HandsRecoil
@export var recoil_rotation_x : Curve
@export var recoil_rotation_z : Curve
@export var recoil_position_z : Curve
@export var recoil_amplitude = Vector3(1,1,1)
@export var lerp_speed : float = 1

#WeaponRecoil
var initial_recoil_amplitude: Vector3 

var target_rot: Vector3
var target_pos: Vector3
var current_time : float

#WeaponChecks
var isBurstActive: bool = false
var burstBullet : int = 0

var isBoltReloaded : bool = false
var removeSmokeMuzzle : bool = false
var being_used : bool = false

var mouse_movement
# Called when the node enters the scene tree for the first time.
func _ready():
	if muzzleSmoke:
		muzzleSmoke.base_width = 0
	initial_recoil_amplitude = recoil_amplitude
	
	weaponData.selectedFireMode = weaponData.fireModes[0]
	current_time = 1
	target_rot.y = rotation.y
	weaponData.bulletsInMag = weaponData.magSize
	
func _input(event):
	if event is InputEventMouseMotion:
		mouse_movement = event.relative

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if not being_used:
		return
		
	if Input.is_action_just_pressed("FireSelection") and weaponData.allowsFireSelection and hands.state_machine.state.name != "Reload":
		fire_selection_sound.play()
		if weaponData.selectedFireModeIndex +1 == weaponData.fireModes.size():
			weaponData.selectedFireMode = weaponData.fireModes[0]
			weaponData.selectedFireModeIndex = 0
		else:
			weaponData.selectedFireModeIndex +=1
			weaponData.selectedFireMode = weaponData.fireModes[weaponData.selectedFireModeIndex]
		
	if hands.state_machine.state.name != "Reload" and not hands.player.seeing_ally:
		if Input.is_action_just_pressed("Fire") and weaponData.bulletsInMag > 0 and weaponData.selectedFireMode == "Semi" and (not hands.state_machine.state.name == "SwappingWeapon" or not hands.state_machine.state.name == "Reload"):
			if (weaponData.weaponType == "Shotgun" or weaponData.weaponType == "Sniper") and (animPlayer.is_playing() or handsAnimPlayer.is_playing()):
				return
			apply_recoil()
			if weaponData.bulletsInMag > 0:
				shoot()
	
		if Input.is_action_pressed("Fire") and weaponData.bulletsInMag > 0 and weaponData.selectedFireMode == "Auto" and time_to_shoot <= 0 and (not hands.state_machine.state.name == "SwappingWeapon" or not hands.state_machine.state.name == "Reload"):
			apply_recoil()
			if weaponData.bulletsInMag > 0:
				shoot()
			time_to_shoot = weaponData.cadency * delta
		
		if (Input.is_action_just_pressed("Fire") or isBurstActive) and weaponData.bulletsInMag > 0 and weaponData.selectedFireMode == "Burst" and time_to_shoot <= 0 and (not hands.state_machine.state.name == "SwappingWeapon" or not hands.state_machine.state.name == "Reload"):
			isBurstActive = true
			apply_recoil()
			if weaponData.bulletsInMag > 0:
				shoot()
				burstBullet += 1
			time_to_shoot = weaponData.cadency * delta
	
		if Input.is_action_just_pressed("Fire") and weaponData.bulletsInMag <= 0 and weaponData.reserveAmmo <= 0:
			if not hands.player.animationPlayer.is_playing():
				hands.player.animationPlayer.play("out_ammo")
				no_ammo_sound.play()
	
	if time_to_shoot > 0:
		time_to_shoot -= 1
	
	if burstBullet == 3 and isBurstActive:
		isBurstActive = false
		burstBullet = 0
	
	if current_time < 1:
		current_time += delta
		
		position.z = lerp(position.z, target_pos.z, lerp_speed * delta)
		rotation.z = lerp(rotation.z, target_rot.z, lerp_speed * delta)
		rotation.x = lerp(rotation.x, target_rot.x, lerp_speed * delta)
		
		target_rot.z = recoil_rotation_z.sample(current_time) * recoil_amplitude.y
		target_rot.x = recoil_rotation_x.sample(current_time) * -recoil_amplitude.x
		target_pos.z = recoil_position_z.sample(current_time) * recoil_amplitude.z
	
	if Input.is_action_just_released("Fire") and weaponData.bulletsInMag > 0 and muzzleSmoke and not hands.player.seeing_ally:
		muzzleSmoke.segments = 20
		muzzleSmoke.emit = true
		muzzleSmoke.base_width = 0.5
		await get_tree().create_timer(1).timeout
		removeSmokeMuzzle = true
	
	if removeSmokeMuzzle and muzzleSmoke.base_width > 0:
		muzzleSmoke.base_width -= 0.01
		if muzzleSmoke.base_width <= 0:
			muzzleSmoke.segments = 0
			removeSmokeMuzzle = false
		
func apply_recoil():
	if Input.is_action_pressed("ADS"):
		recoil_amplitude.y *= -0.2 if randf() > 0.5 else 0.2
	else:
		recoil_amplitude = initial_recoil_amplitude
		recoil_amplitude.y *= -1 if randf() > 0.5 else 1
		
	target_rot.z = recoil_rotation_z.sample(0) * recoil_amplitude.y
	target_rot.x = recoil_rotation_x.sample(0) * -recoil_amplitude.x
	target_pos.z = recoil_position_z.sample(0) * recoil_amplitude.z
	current_time = 0

func shoot():
	#get recoil script from child node and apply some to the weapon
	if Input.is_action_pressed("ADS"):
		hands.player.eyes.get_child(0).recoilFire(true)
	else:
		hands.player.eyes.get_child(0).recoilFire()
	weaponData.bulletsInMag -= 1

	animPlayer.play("RESET")
	animPlayer.play("Shoot")
	handsAnimPlayer.play("RESET")
	handsAnimPlayer.play(weaponData.name + "_Shot")
	if fire_sound:
		SFXHandler.play_sfx(fire_sound.stream, self, "Weapons")
	spawnBullet()

func spawnBullet():
	var level_root = get_tree().get_root()
	if weaponData.weaponType == "Shotgun":
		for x in range(8):
			var bullet : Bullet = bullet_type.instantiate()
			bullet.instigator = hands.player
			bullet.transform = muzzle.global_transform
			bullet.linear_velocity = muzzle.global_transform.basis.x * 1000
			bullet.linear_velocity += muzzle.global_transform.basis.z * randf_range(-20, 20)
			bullet.linear_velocity += muzzle.global_transform.basis.y * randf_range(-20, 20)
			bullet.damage = weaponData.damage
			bullet.hitmark.connect(show_hitmarker)
			bullet.hitmark.connect(hit_update_score)
			bullet.playerDamaged.connect(update_health)
			bullet.kill.connect(kill_update_score)
			
			level_root.add_child(bullet)
	else:
		var bullet : Bullet = bullet_type.instantiate()
		bullet.instigator = hands.player
		bullet.transform = muzzle.global_transform
		bullet.linear_velocity = muzzle.global_transform.basis.x * 1000
		bullet.damage = weaponData.damage
		#if player gets damaged
		bullet.playerDamaged.connect(update_health)
		#Hitmarker in hud
		bullet.hitmark.connect(hit_update_score)
		bullet.hitmark.connect(show_hitmarker)
		#For when player kills somebody (atm just for update hud points)
		bullet.kill.connect(kill_update_score)
		
		level_root.add_child(bullet)

	muzzle_flash_particles.emitting = true
	muzzle_flash_light.show()
	
	await get_tree().create_timer(0.05).timeout
	
	muzzle_flash_light.hide()
	
	if weaponData.weaponType == "Sniper":
		await get_tree().create_timer(0.6).timeout
	
	bullet_case_particles.emitting = true

func show_hitmarker(points):
	if hands.player.hud.animationPlayer.current_animation == "hitmarker":
		hands.player.hud.animationPlayer.play("RESET")
	hands.player.hud.animationPlayer.play("hitmarker")

func kill_update_score(points):
	if hands.player.hud.timerContainer.visible == true:
		hands.player.hud.pointsLabel.text = str(int(hands.player.hud.pointsLabel.text) + points)

func hit_update_score(points):
	if hands.player.hud.timerContainer.visible == true:
		hands.player.hud.pointsLabel.text = str(int(hands.player.hud.pointsLabel.text) + points)

func update_health():
	hands.player.hud.healthBar.value = hands.player.health

func _on_animation_player_animation_finished(anim_name):
	if anim_name == weaponData.name + "_Shot" and weaponData.isBoltAction:
		handsAnimPlayer.play(weaponData.name + "_Bolt")
	
	if anim_name == weaponData.name + "_Bolt" and isBoltReloaded == false:
		isBoltReloaded =  true
		handsAnimPlayer.play(weaponData.name + "_Bolt", -1, -1, true)
	
	elif anim_name == weaponData.name + "_Bolt" and isBoltReloaded == true:
		isBoltReloaded =  false

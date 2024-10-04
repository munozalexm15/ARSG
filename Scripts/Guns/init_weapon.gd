class_name Weapon
extends Node3D

@export var weaponData : WeaponData

#MAG WEAPONS (reload_sound it is also used in bolt weapons)
@onready var fire_sound : AudioStreamPlayer3D = $ASP_ShotShound
@onready var reload_sound : AudioStreamPlayer3D = $ASP_ReloadSound
var full_reload_sound : AudioStreamPlayer3D

#Bolt action weapons, shotguns, etc.
var bolt_back_sound : AudioStreamPlayer3D
var bolt_forward_sound : AudioStreamPlayer3D

@export var handsNode := NodePath()
@onready var hands : Arms = get_node(handsNode)

@onready var leftArm : MeshInstance3D = $Player_Arms/Armature_001/Skeleton3D/Cube_002
@onready var rightArm  : MeshInstance3D= $Player_Arms/Armature_001/Skeleton3D/Cube_001

@onready var handsAnimPlayer = $Player_Arms/AnimationPlayer

#Weapon parts
@onready var muzzle = $Muzzle
@onready var muzzleSmoke : Trail3D = $Muzzle/MuzzleSmoke
@export var bullet_type: PackedScene
@onready var bullet_case_particles : CPUParticles3D = $Bullet_Case_Particles
@onready var muzzle_flash_particles : GPUParticles3D = $Muzzle/MuzzleFlash
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
	if not is_multiplayer_authority():
		return
	if muzzleSmoke:
		muzzleSmoke.base_width = 0
	initial_recoil_amplitude = recoil_amplitude
	
	weaponData = weaponData.duplicate()
	
	weaponData.selectedFireMode = weaponData.fireModes[0]
	current_time = 1
	target_rot.y = rotation.y
	weaponData.bulletsInMag = weaponData.magSize
	
	if weaponData.weaponType == "Sniper" or weaponData.weaponType == "Shotgun":
		bolt_back_sound = $ASP_BoltBackSound
		bolt_forward_sound = $ASP_BoltForwardSound
	else:
		full_reload_sound = $ASP_FullReloadSound
	
func _input(event):
	if not is_multiplayer_authority():
		return
		
	if event is InputEventMouseMotion:
		mouse_movement = event.relative

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if not is_multiplayer_authority():
		return
	
	if not being_used:
		return
	
	if hands.player.isPauseMenuOpened:
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
			if (weaponData.weaponType == "Shotgun" or weaponData.weaponType == "Sniper") and handsAnimPlayer.is_playing():
				return
			if weaponData.bulletsInMag > 0:
				load_recoil.rpc()
				shoot()

		if Input.is_action_pressed("Fire") and weaponData.bulletsInMag > 0 and weaponData.selectedFireMode == "Auto" and time_to_shoot <= 0 and (not hands.state_machine.state.name == "SwappingWeapon" or not hands.state_machine.state.name == "Reload"):
			if weaponData.bulletsInMag > 0:
				load_recoil.rpc()
				shoot()
			time_to_shoot = weaponData.cadency * delta
		
		if (Input.is_action_just_pressed("Fire") or isBurstActive) and weaponData.bulletsInMag > 0 and weaponData.selectedFireMode == "Burst" and time_to_shoot <= 0 and (not hands.state_machine.state.name == "SwappingWeapon" or not hands.state_machine.state.name == "Reload"):
			isBurstActive = true
			if weaponData.bulletsInMag > 0:
				load_recoil.rpc()
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

	apply_recoil.rpc(delta)
	
	# MUZZLE SMOKE : DISABLED ATM
	#if Input.is_action_just_released("Fire") and weaponData.bulletsInMag > 0 and muzzleSmoke and not hands.player.seeing_ally:
		#muzzleSmoke.segments = 20
		#muzzleSmoke.emit = true
		#muzzleSmoke.base_width = 0.5
		#await get_tree().create_timer(1).timeout
		#removeSmokeMuzzle = true
	#
	#if removeSmokeMuzzle and muzzleSmoke.base_width > 0:
		#muzzleSmoke.base_width -= 0.01
		#if muzzleSmoke.base_width <= 0:
			#muzzleSmoke.segments = 0
			#removeSmokeMuzzle = false

@rpc("any_peer", "call_local", "reliable")
func apply_recoil(delta):
	if current_time < 1:
		current_time += delta
		
		position.z = lerp(position.z, target_pos.z, lerp_speed * delta)
		rotation.z = lerp(rotation.z, target_rot.z, lerp_speed * delta)
		rotation.x = lerp(rotation.x, target_rot.x, lerp_speed * delta)
		
		target_rot.z = recoil_rotation_z.sample(current_time) * recoil_amplitude.y
		target_rot.x = recoil_rotation_x.sample(current_time) * -recoil_amplitude.x
		target_pos.z = recoil_position_z.sample(current_time) * recoil_amplitude.z


@rpc("authority", "call_local", "reliable")
func load_recoil():
	if Input.is_action_pressed("ADS"):
		recoil_amplitude.y *= -0.1 if randf() > 0.5 else 0.1
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
		hands.player.eyes.get_child(0).recoilFire.rpc(true)
	else:
		hands.player.eyes.get_child(0).recoilFire.rpc(false)
	weaponData.bulletsInMag -= 1
	
	#Setting boltreloaded to true, to force players to play the bolt animation first and prevent reload spamming
	if weaponData.isBoltAction:
		isBoltReloaded = true
		
	handsAnimPlayer.play("RESET")
	handsAnimPlayer.play(weaponData.name + "_Shot")
	
	spawnBullet.rpc()
	

@rpc("authority", "call_local", "reliable")
func spawnBullet():
	if fire_sound:
		SFXHandler.play_sfx_3d(fire_sound.stream.resource_path, hands.player.name, "Weapons", 100.0)
	
	var _level_root = Network.game
	if weaponData.weaponType == "Shotgun":
		for x in range(8):
			var bullet : Bullet = bullet_type.instantiate()
		
			bullet.hitmark.connect(show_hitmarker)
			bullet.hitmark.connect(hit_update_score)
			bullet.playerDamaged.connect(update_health)
			bullet.kill.connect(kill_update_score)
			
			Network.game.bullets_node.add_child(bullet)
			
			bullet.instigator = hands.player
			bullet.transform = muzzle.global_transform
			
			if hands.player.state_machine.state.name == "Crouch":
				bullet.position.y -= 0.06
			
			bullet.linear_velocity = muzzle.global_transform.basis.x * 1000
			bullet.linear_velocity += muzzle.global_transform.basis.z * randf_range(-160, 160)
			bullet.linear_velocity += muzzle.global_transform.basis.y * randf_range(-160, 160)
			
			bullet.damage = weaponData.damage
	else:
		var bullet : Bullet = bullet_type.instantiate()
		bullet.instigator = hands.player
		
		#if player gets damaged
		bullet.playerDamaged.connect(update_health)
		#Hitmarker in hud
		bullet.hitmark.connect(hit_update_score)
		bullet.hitmark.connect(show_hitmarker)
		#For when player kills somebody (atm just for update hud points)
		bullet.kill.connect(kill_update_score)
		
		Network.game.bullets_node.add_child(bullet)
		bullet.transform = muzzle.global_transform
		
		if hands.player.state_machine.state.name == "Crouch":
			bullet.position.y -= 0.06
			
		bullet.linear_velocity = muzzle.global_transform.basis.x * 1000
		bullet.damage = weaponData.damage
		
	show_muzzleFlash()

func show_muzzleFlash():
	if not is_multiplayer_authority():
		return
	muzzle_flash_particles.emitting = true
	muzzle_flash_light.show()
	
	await get_tree().create_timer(0.05).timeout
	
	muzzle_flash_light.hide()
	
	if weaponData.weaponType == "Sniper":
		await get_tree().create_timer(0.6).timeout
	
	bullet_case_particles.emitting = true

func show_hitmarker(_points):
	if hands.player.hud.animationPlayer.current_animation == "hitmarker":
		hands.player.hud.animationPlayer.play("RESET")
	hands.player.hud.animationPlayer.play("hitmarker")
	var audioSteam : AudioStream = load("res://GameResources/Sounds/Misc/hitmarker_sound.wav")
	var stream = AudioStreamPlayer3D.new()
	SFXHandler.play_sfx(stream, hands.player, "Effects")

func kill_update_score(points):
	if hands.player.hud.timerContainer.visible == true:
		hands.player.hud.pointsLabel.text = str(int(hands.player.hud.pointsLabel.text) + points)

func hit_update_score(points):
	if hands.player.hud.timerContainer.visible == true:
		hands.player.hud.pointsLabel.text = str(int(hands.player.hud.pointsLabel.text) + points)

func update_health():
	if not is_multiplayer_authority():
		return
	hands.player.hud.healthBar.value = hands.player.health
	

func _on_animation_player_animation_finished(anim_name):
	if anim_name == weaponData.name + "_Shot" and weaponData.isBoltAction:
		isBoltReloaded = true
		handsAnimPlayer.play(weaponData.name + "_Bolt")
		handsAnimPlayer.assigned_animation = weaponData.name + "_Bolt"
	
	if anim_name == weaponData.name + "_Bolt" and handsAnimPlayer.assigned_animation == weaponData.name + "_Bolt" and isBoltReloaded:
		handsAnimPlayer.play(weaponData.name + "_Bolt", -1, -1, true)
		isBoltReloaded = false
		await handsAnimPlayer.animation_finished
		handsAnimPlayer.play("RESET")
		handsAnimPlayer.assigned_animation = "RESET"
		
		

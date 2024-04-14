extends Node3D

signal reload()

@export var weaponData : Weapon

@export var handsNode := NodePath()
@onready var hands : Node3D = get_node(handsNode)

@onready var animPlayer = $AnimationPlayer
@onready var handsAnimPlayer = $Player_Arms/AnimationPlayer

@onready var muzzle = $Muzzle
@export var bullet_type: PackedScene
@onready var bullet_case_particles : CPUParticles3D = $Bullet_Case_Particles
@onready var muzzle_flash_particles :CPUParticles3D = $Muzzle/MuzzleFlash
@onready var muzzle_flash_light : OmniLight3D = $Muzzle/MuzzleFlashLight
var time_to_shoot = 0

#HandsRecoil
@export var recoil_rotation_x : Curve
@export var recoil_rotation_z : Curve
@export var recoil_position_z : Curve
@export var recoil_amplitude = Vector3(1,1,1)
@export var lerp_speed : float = 1

var target_rot: Vector3
var target_pos: Vector3
var current_time : float



# Called when the node enters the scene tree for the first time.
func _ready():
	current_time = 1
	target_rot.y = rotation.y
	weaponData.bulletsInMag = weaponData.magSize

func _input(event):
	if Input.is_action_just_pressed("Fire") and weaponData.bulletsInMag > 0 and not weaponData.isAutomatic:
		apply_recoil()
		if weaponData.bulletsInMag > 0:
			shoot()
		if weaponData.bulletsInMag <= 0:
			reload.emit()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if Input.is_action_pressed("Fire") and weaponData.bulletsInMag > 0 and weaponData.isAutomatic and time_to_shoot <= 0:
		apply_recoil()
		if weaponData.bulletsInMag > 0:
			shoot()
		if weaponData.bulletsInMag <= 0 and weaponData.reserveAmmo > 0:
			reload.emit()
		time_to_shoot = weaponData.cadency
	
	if time_to_shoot > 0:
		time_to_shoot -= 1
	
	if current_time < 1:
		current_time += delta
		position.z = lerp(position.z, target_pos.z, lerp_speed * delta)
		rotation.z = lerp(rotation.z, target_rot.z, lerp_speed * delta)
		rotation.x = lerp(rotation.x, target_rot.x, lerp_speed * delta)
		
		target_rot.z = recoil_rotation_z.sample(current_time) * recoil_amplitude.y
		target_rot.x = recoil_rotation_x.sample(current_time) * -recoil_amplitude.x
		target_pos.z = recoil_position_z.sample(current_time) * recoil_amplitude.z

func apply_recoil():
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
	spawnBullet()

func spawnBullet():
	var level_root = get_tree().get_root()
	
	#Spawn bullet
	var bullet : RigidBody3D = bullet_type.instantiate()
	bullet.transform = muzzle.global_transform
	bullet.linear_velocity = muzzle.global_transform.basis.x * 1000
	bullet_case_particles.emitting = true
	muzzle_flash_particles.emitting = true
	level_root.add_child(bullet)
	muzzle_flash_light.show()
	
	await get_tree().create_timer(0.05).timeout
	muzzle_flash_light.hide()
	

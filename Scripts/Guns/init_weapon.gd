extends Node3D
@onready var animPlayer = $AnimationPlayer
@onready var handsAnimPlayer = $Player_Arms/AnimationPlayer

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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("Fire"):
		animPlayer.play("RESET")
		animPlayer.play("Shoot")
		handsAnimPlayer.play("RESET")
		handsAnimPlayer.play("Pistol_Shoot")
		apply_recoil()
		
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

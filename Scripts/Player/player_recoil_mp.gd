class_name Player_Recoil
extends Node3D

@onready var leftArmNode = $"."
@onready var rightArmNode = $"../../RightArmShoulder/RightArmTarget"
# Rotations
var currentRotation : Vector3
var targetRotation : Vector3
var beforeShootRotation : Vector3

var originalHandPos : Vector3
var originalHandRot : Vector3
# Recoil vectors
@export var recoil : Vector3
@export var aimRecoil : Vector3

# Settings
@export var snappiness : float
@export var returnSpeed : float

@onready var skeleton : PlayerSkeleton = $"../.."

func _ready():
	originalHandPos = leftArmNode.position
	originalHandRot = rotation

func _process(delta):
	if not is_multiplayer_authority():
		return
		# Lerp target rotation to (0,0,0) and lerp current rotation to target rotation
	targetRotation = lerp(targetRotation, originalHandPos , returnSpeed * delta)
	currentRotation = lerp(leftArmNode.position, targetRotation, snappiness * delta)
	
	# Set rotation
	position = currentRotation
	rotation.x = skeleton.arms.player.eyes.get_child(0).targetRotation.x * 4
	# Camera z axis tilt fix, ignored if tilt intentionals
	# I have no idea why it tilts if recoil.z is set to 0
	if recoil.z == 0 and aimRecoil.z == 0:
		global_position.z = 0
	
	var fullAutoReq = skeleton.arms.state_machine.state.name == "Idle" and skeleton.arms.actualWeapon.weaponData.bulletsInMag > 0 and skeleton.arms.actualWeapon.weaponData.selectedFireMode == "Auto"
	var semiReq = skeleton.arms.state_machine.state.name == "Idle" and skeleton.arms.actualWeapon.weaponData.bulletsInMag > 0 and skeleton.arms.actualWeapon.weaponData.selectedFireMode == "Semi"
	var burstReq = skeleton.arms.state_machine.state.name == "Idle" and skeleton.arms.actualWeapon.weaponData.bulletsInMag > 0 and skeleton.arms.actualWeapon.weaponData.selectedFireMode == "Burst"
	if Input.is_action_pressed("Fire") and fullAutoReq:
		recoilFire()
	
	if Input.is_action_just_pressed("Fire") and semiReq:
		recoilFire()
	
	if skeleton.arms.actualWeapon.isBurstActive and burstReq:
		recoilFire()

func recoilFire(isAiming : bool = false):
	if isAiming:
		targetRotation += Vector3(aimRecoil.x, randf_range(-aimRecoil.y, aimRecoil.y), randf_range(-aimRecoil.z, aimRecoil.z))
	else:
		targetRotation += Vector3(recoil.x , randf_range(-recoil.y, recoil.y), randf_range(-recoil.z - 0.01, -recoil.z))
	

func setRecoil(newRecoil : Vector3):
	recoil = newRecoil

func setAimRecoil(newRecoil : Vector3):
	aimRecoil = newRecoil

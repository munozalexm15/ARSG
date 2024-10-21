class_name Player_Recoil
extends Node3D

@export var targetNodePath := NodePath()
@onready var targetNode : Node3D = get_node(targetNodePath)

@export var multiplierValue : int

@export var skeletonNodePath := NodePath()
@onready var skeleton : PlayerSkeleton = get_node(skeletonNodePath)

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

func _ready():
	originalHandPos = targetNode.position
	originalHandRot = rotation

func _process(delta):
	if not is_multiplayer_authority():
		return
	
	if not skeleton.arms.weaponHolder.get_child_count() > 0:
		return
		# Lerp target rotation to (0,0,0) and lerp current rotation to target rotation
	targetRotation = lerp(targetRotation, originalHandPos , returnSpeed * delta)
	currentRotation = lerp(targetNode.position, targetRotation, snappiness * delta)
	
	# Set rotation
	position = currentRotation
	rotation.x = skeleton.arms.player.eyes.get_child(0).targetRotation.x * multiplierValue
	# Camera z axis tilt fix, ignored if tilt intentionals
	# I have no idea why it tilts if recoil.z is set to 0
	if recoil.z == 0 and aimRecoil.z == 0:
		global_position.z = 0
	
	var fullAutoReq = skeleton.arms.state_machine.state.name == "Idle" and skeleton.arms.actualWeapon.weaponData.bulletsInMag > 0 and skeleton.arms.actualWeapon.weaponData.selectedFireMode == "Auto"
	var semiReq = skeleton.arms.state_machine.state.name == "Idle" and skeleton.arms.actualWeapon.weaponData.bulletsInMag > 0 and skeleton.arms.actualWeapon.weaponData.selectedFireMode == "Semi"
	var burstReq = skeleton.arms.state_machine.state.name == "Idle" and skeleton.arms.actualWeapon.weaponData.bulletsInMag > 0 and skeleton.arms.actualWeapon.weaponData.selectedFireMode == "Burst"
	
	if skeleton.arms.player.isPauseMenuOpened:
		return
	if Input.is_action_pressed("Fire") and fullAutoReq:
		recoilFire.rpc(multiplayer.get_unique_id() , false)
	
	if Input.is_action_just_pressed("Fire") and semiReq:
		recoilFire.rpc(multiplayer.get_unique_id() , false)
	
	if skeleton.arms.actualWeapon.isBurstActive and burstReq:
		recoilFire.rpc(multiplayer.get_unique_id(), false)

@rpc("any_peer", "call_local", "reliable")
func recoilFire(identifier, isAiming : bool):
	var player : Player = null
	for p : Player in Network.game.players_node.get_children():
		if p.name == str(identifier):
			player = p
	
	if player == null:
		return
		
	if isAiming:
		targetRotation += Vector3(aimRecoil.x, randf_range(-aimRecoil.y, aimRecoil.y), randf_range(-aimRecoil.z, aimRecoil.z))
	else:
		targetRotation += Vector3(recoil.x , randf_range(-recoil.y, recoil.y), randf_range(-recoil.z - 0.01, -recoil.z))

func setRecoil(newRecoil : Vector3):
	recoil = newRecoil

func setAimRecoil(newRecoil : Vector3):
	aimRecoil = newRecoil

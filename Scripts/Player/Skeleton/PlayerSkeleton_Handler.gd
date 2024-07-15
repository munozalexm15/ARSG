class_name PlayerSkeleton
extends Node3D

signal updatedPose(weaponName)

@export var eyesHolderNode := NodePath()
@onready var eyesHolder : Node3D = get_node(eyesHolderNode)

@export var armsNode := NodePath()
@onready var arms : Arms = get_node(armsNode)

@onready var animationTree : AnimationTree = $AnimationTree
@onready var animationPlayer : AnimationPlayer = $PlayerModel/AnimationPlayer

@onready var LeftHandB_Attachment : BoneAttachment3D = $PlayerModel/Armature/Skeleton3D/LeftHand_BAttachment

var actualWeaponName = ""

@onready var leftArmShoulder: Node3D = $LeftArmShoulder
@onready var rightArmShoulder: Node3D = $RightArmShoulder

var leftShoulderHeight
var rightShoulderHeight

@onready var headTarget : Node3D = $HeadTarget
@onready var leftArmTarget: Player_Recoil = $LeftArmShoulder/LeftArmTarget
@onready var rightArmTarget : Node3D = $RightArmShoulder/RightArmTarget

var standingRightArmTargetPosition : Vector3
var standingLeftArmTargetPosition : Vector3

@onready var headIKSkeleton : SkeletonIK3D = $PlayerModel/Armature/Skeleton3D/HeadIK3D
@onready var leftArmIKSkeleton : SkeletonIK3D = $PlayerModel/Armature/Skeleton3D/LeftArmIK3D
@onready var rightArmIKSkeleton : SkeletonIK3D = $PlayerModel/Armature/Skeleton3D/RightArmIK3D
#Este script de encargara de cargar en las manos del jugador el mesh del arma que esta usando
#y seguramente, otras cosas.

#Este modelo solo es visible desde el POV de otros jugadores, tu no podras ver el tuyo, pero si el
#de otros

#a futuro, se añadira customizacion (cambiar la textura del material del personaje) y alguna
#tonteria mas.

# Called when the node enters the scene tree for the first time.
func _ready():
	leftArmIKSkeleton.interpolation = 0.5
	rightArmIKSkeleton.interpolation = 1
	headIKSkeleton.interpolation = 0.5
	leftArmIKSkeleton.start()
	headIKSkeleton.start()
	rightArmIKSkeleton.start()
	leftShoulderHeight = leftArmShoulder.position.y
	rightShoulderHeight = rightArmShoulder.position.y

func _process(_delta):
	headTarget.rotation.x = -arms.player.eyes.rotation.x * 2
	rightArmShoulder.rotation.x = (-arms.player.eyes.rotation.x / 2)
	leftArmShoulder.rotation.x = -arms.player.eyes.rotation.x * 2
	
	#Get main_Character "arms Holder" node
	if (LeftHandB_Attachment.get_child_count() > 0):
		rightArmIKSkeleton.target_node = LeftHandB_Attachment.get_child(0).rHand_grip.get_path()

func _on_arms_player_swapping_weapons():
	if not is_multiplayer_authority():
		return
		
	actualWeaponName = arms.actualWeapon.weaponData.name
	update_anim(arms.actualWeapon.weaponData.weaponType)
	var actualWeapon : PackedScene = arms.actualWeapon.weaponData.weaponExternalScene
	var spawnedWeapon : WeaponSkeleton = actualWeapon.instantiate()

	for child in LeftHandB_Attachment.get_children():
		LeftHandB_Attachment.remove_child(child)

	LeftHandB_Attachment.add_child(spawnedWeapon)
	
	leftArmTarget.originalHandPos = spawnedWeapon.weaponSkeletonData.LeftHandPosition
	
	leftArmTarget.position = spawnedWeapon.weaponSkeletonData.LeftHandPosition
	leftArmTarget.rotation = spawnedWeapon.weaponSkeletonData.LeftHandRotation
	rightArmTarget.position = spawnedWeapon.weaponSkeletonData.RightHandPosition
	rightArmTarget.rotation = spawnedWeapon.weaponSkeletonData.RightHandRotation
	
func update_anim(weapon):
	updatedPose.emit(weapon)
	pass
	
	#if weapon == "AR":
		#animationPlayer.play("Player_Rifle_Idle")
	#
	#if weapon == "Pistol":
		#animationPlayer.play("Player_Pistol_Idle")
	#

func _on_animation_player_animation_finished(_anim_name):
	if LeftHandB_Attachment.override_pose == true:
		LeftHandB_Attachment.override_pose = false
	if arms.player.state == "Idle":
		animationPlayer.play("Idle")

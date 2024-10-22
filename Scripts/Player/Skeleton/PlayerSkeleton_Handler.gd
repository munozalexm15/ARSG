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
@onready var playerMesh : MeshInstance3D = $PlayerModel/Armature/Skeleton3D/PoliceOfficer

#ADS positions to lerp-----------------------
@export var leftArmADSPosition : Vector3
@export var rightArmADSPosition : Vector3

var originalLeftArmPosition : Vector3
var originalRightArmPosition : Vector3
#--------------------------------------

@onready var headTarget : Node3D = $HeadTarget
@onready var leftArmTarget: Player_Recoil = $LeftArmShoulder/LeftArmTarget
@onready var rightArmTarget : Node3D = $RightArmShoulder/RightArmTarget

@onready var headIKSkeleton : SkeletonIK3D = $PlayerModel/Armature/Skeleton3D/HeadIK3D
@onready var leftArmIKSkeleton : SkeletonIK3D = $PlayerModel/Armature/Skeleton3D/LeftArmIK3D
@onready var rightArmIKSkeleton : SkeletonIK3D = $PlayerModel/Armature/Skeleton3D/RightArmIK3D
@onready var chestIKSkeleton : SkeletonIK3D = $PlayerModel/Armature/Skeleton3D/ChestIK3D

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
	chestIKSkeleton.start()

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Crouch"):
		leftArmShoulder.position.y -= 0.75
		rightArmShoulder.position.y -= 0.75
	if Input.is_action_just_released("Crouch"):
		leftArmShoulder.position.y += 0.75
		rightArmShoulder.position.y += 0.75

func _process(_delta):
	headTarget.rotation.x = -arms.player.eyes.rotation.x * 2
	
	if arms.player.state_machine.state.name != "Run":
		rightArmShoulder.rotation.x = -arms.player.eyes.rotation.x / 2
		leftArmShoulder.rotation.x = -arms.player.eyes.rotation.x * 2
	else:
		rightArmShoulder.rotation.x = lerp(rightArmShoulder.rotation.x, 0.00, _delta * 2)
		leftArmShoulder.rotation.x = lerp(leftArmShoulder.rotation.x, 0.00, _delta * 2)
	
	if Input.is_action_pressed("ADS") and arms.state_machine.state.name != "Reload":
		leftArmTarget.originalHandPos.x = leftArmADSPosition.x + + abs(arms.player.eyes.rotation.x / 2) * -1
		leftArmTarget.originalHandPos.y = leftArmADSPosition.y + abs(arms.player.eyes.rotation.x / 2) * -1
	else:
		leftArmTarget.originalHandPos = originalLeftArmPosition
	
	#Get main_Character "arms Holder" node -- Make it a signal for better performance
	if (LeftHandB_Attachment.get_child_count() > 0):
		rightArmIKSkeleton.target_node = LeftHandB_Attachment.get_child(0).rHand_grip.get_path()
		if arms.player.camera.current:
			LeftHandB_Attachment.get_child(0).visible = false

func _on_arms_player_swapping_weapons():
	if not is_multiplayer_authority():
		return
	
	if not arms.weaponHolder.get_child_count() > 0:
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
	originalLeftArmPosition = leftArmTarget.position
	originalRightArmPosition = rightArmTarget.position
	
func update_anim(weapon):
	updatedPose.emit(weapon)

func _on_animation_player_animation_finished(_anim_name):
	if LeftHandB_Attachment.override_pose == true:
		LeftHandB_Attachment.override_pose = false
	if arms.player.state == "Idle":
		animationPlayer.play("Idle")


func _on_animation_tree_animation_finished(anim_name : String):
	
	var animType: Array = anim_name.split("_")
	
	if animType[0] == "Reload":
		leftArmIKSkeleton.interpolation = 0.5
		rightArmIKSkeleton.interpolation = 1

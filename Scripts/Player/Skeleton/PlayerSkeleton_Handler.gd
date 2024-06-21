class_name PlayerSkeleton
extends Node3D


@export var eyesHolderNode := NodePath()
@onready var eyesHolder : Node3D = get_node(eyesHolderNode)

@export var armsNode := NodePath()
@onready var arms : Arms = get_node(armsNode)

@onready var animationPlayer : AnimationPlayer = $player_standing_anims/AnimationPlayer

@onready var skeleton : Skeleton3D = $player_standing_anims/Armature/Skeleton3D
@onready var LeftHandB_Attachment : BoneAttachment3D = $player_standing_anims/Armature/Skeleton3D/LeftHand_BAttachment


#Este script de encargara de cargar en las manos del jugador el mesh del arma que esta usando
#y seguramente, otras cosas.

#Este modelo solo es visible desde el POV de otros jugadores, tu no podras ver el tuyo, pero si el
#de otros

#a futuro, se añadira customizacion (cambiar la textura del material del personaje) y alguna
#tonteria mas.

# Called when the node enters the scene tree for the first time.
func _ready():
	skeleton.eyesHolder = eyesHolder
	animationPlayer.play("Player_Pistol_Idle")
	var weaponHolding : WeaponSkeleton = LeftHandB_Attachment.get_child(0)
	
	#en adelante sera statemachine
	if weaponHolding.weaponSkeletonData.weaponType == "Rifle":
		animationPlayer.play("Player_Rifle_Idle")
	
	if weaponHolding.weaponSkeletonData.weaponType == "Pistol":
		animationPlayer.play("Player_Pistol_Idle")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_arms_player_swapping_weapons():
	var actualWeapon : WeaponData = arms.actualWeapon
	LeftHandB_Attachment.add_child(arms.actualWeapon)

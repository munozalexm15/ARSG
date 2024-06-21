class_name PlayerSkeleton
extends Node3D

signal updatedPose

@export var eyesHolderNode := NodePath()
@onready var eyesHolder : Node3D = get_node(eyesHolderNode)

@export var armsNode := NodePath()
@onready var arms : Arms = get_node(armsNode)

@onready var animationPlayer : AnimationPlayer = $player_standing_anims/AnimationPlayer

@onready var skeleton : Skeleton3D = $player_standing_anims/Armature/Skeleton3D
@onready var LeftHandB_Attachment : BoneAttachment3D = $player_standing_anims/Armature/Skeleton3D/LeftHand_BAttachment

var actualWeaponName = ""

#Este script de encargara de cargar en las manos del jugador el mesh del arma que esta usando
#y seguramente, otras cosas.

#Este modelo solo es visible desde el POV de otros jugadores, tu no podras ver el tuyo, pero si el
#de otros

#a futuro, se añadira customizacion (cambiar la textura del material del personaje) y alguna
#tonteria mas.

# Called when the node enters the scene tree for the first time.
func _ready():
	skeleton.eyesHolder = eyesHolder
	skeleton.arms = arms

func _on_arms_player_swapping_weapons():
	updatedPose.emit()
	if not multiplayer.connected_to_server:
		return
	
	actualWeaponName = arms.actualWeapon.weaponData.name
	update_anim(arms.actualWeapon.weaponData.weaponType)
	
	var actualWeapon : PackedScene = arms.actualWeapon.weaponData.weaponExternalScene
	var spawnedWeapon = actualWeapon.instantiate()
	
	for child in LeftHandB_Attachment.get_children():
		LeftHandB_Attachment.remove_child(child)
	
	LeftHandB_Attachment.add_child(spawnedWeapon)
	spawnedWeapon.position = LeftHandB_Attachment.position

func update_anim(weapon):
	if weapon == "AR":
		animationPlayer.play("Player_Rifle_Idle")
	
	if weapon == "Pistol":
		animationPlayer.play("Player_Pistol_Idle")

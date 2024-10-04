class_name WeaponSkeleton
extends Node3D

#script que sirve para poder asignarle un resource de tipo weaponSkeletonData, que servira
#para saber la posicion, rotacion, etc. respecto a las manos del jugador desde el POV de otros

@export var weaponSkeletonData : WeaponSkeletonData

@onready var rHand_grip : Node3D = $RHand_Grip

@onready var muzzleFlash : GPUParticles3D = $MuzzleFlash
@onready var muzzleFlashLight : OmniLight3D = $MuzzleFlashLight
# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func _on_muzzle_flash_finished() -> void:
	muzzleFlashLight.visible = false

class_name WeaponSkeleton
extends Node3D

#script que sirve para poder asignarle un resource de tipo weaponSkeletonData, que servira
#para saber la posicion, rotacion, etc. respecto a las manos del jugador desde el POV de otros

@export var weaponSkeletonData : WeaponSkeletonData

@onready var MuzzleFlash : CPUParticles3D = $Muzzle/MuzzleFlash
@onready var MuzzleFlashlight : OmniLight3D = $Muzzle/MuzzleFlashLight
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _process(delta):
	if Input.is_action_just_pressed("Fire"):
		MuzzleFlash.emitting = true
		MuzzleFlashlight.visible = true

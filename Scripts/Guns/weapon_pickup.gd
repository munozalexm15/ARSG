class_name WeaponInteractable
extends RigidBody3D

@export var weaponData : WeaponData

var isPickupReady = false
var isAlreadyGrabbed = false

var id = 0

# Called when the node enters the scene tree for the first time.
func _ready():

	await get_tree().create_timer(1).timeout
	isPickupReady = true

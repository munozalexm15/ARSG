class_name Interactable
extends RigidBody3D

@export var weaponData : WeaponData

var isPickupReady = false

# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().create_timer(2).timeout
	isPickupReady = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


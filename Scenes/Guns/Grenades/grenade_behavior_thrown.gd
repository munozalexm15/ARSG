class_name GrenadeThrown
extends RigidBody3D

@onready var detonationTimer : Timer = $DetonationTime
@onready var greandeMeshParent : Node3D = $grenade
@onready var damageArea : Area3D = $Area3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_detonation_time_timeout() -> void:
	print("bum")

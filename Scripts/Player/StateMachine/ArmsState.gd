class_name ArmsState
extends State

var arms: Arms

func _ready() -> void:
	await owner.ready
	arms = owner as Node3D
	assert(arms != null)

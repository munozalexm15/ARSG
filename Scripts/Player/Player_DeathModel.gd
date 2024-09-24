extends Node3D


@onready var animationPlayer : AnimationPlayer = $ModelParent/AnimationPlayer

@onready var parent : Node3D = $ModelParent

@onready var playerMesh : MeshInstance3D = $ModelParent/Armature/Skeleton3D/PoliceOfficer

# Called when the node enters the scene tree for the first time.
func _ready():
	scale = Vector3(0.5, 0.5, 0.5)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

extends Node3D


@onready var animationPlayer : AnimationPlayer = $RigidBody3D/ModelParent/AnimationPlayer

@onready var parent : Node3D = $RigidBody3D/ModelParent

@onready var playerMesh : MeshInstance3D = $RigidBody3D/ModelParent/Armature/Skeleton3D/PoliceOfficer
@onready var collShape : CollisionShape3D = $RigidBody3D/CollisionShape3D
var anims = null
var selectedPos = null

var playAnim = true
# Called when the node enters the scene tree for the first time.
func _ready():
	scale = Vector3(0.5, 0.5, 0.5)
	anims = animationPlayer.get_animation_list()
	selectedPos = randi() % anims.size()
	animationPlayer.play(anims[selectedPos])
	parent.scale = Vector3(0.5, 0.5, 0.5)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	pass

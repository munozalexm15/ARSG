extends Node3D


@onready var animationPlayer : AnimationPlayer = $ModelParent/AnimationPlayer

@onready var parent : Node3D = $ModelParent

@onready var playerMesh : MeshInstance3D = $ModelParent/Armature/Skeleton3D/PoliceOfficer
var anims = animationPlayer.get_animation_list()
var selectedPos = randi() % anims.size()
# Called when the node enters the scene tree for the first time.
func _ready():
	scale = Vector3(0.5, 0.5, 0.5)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	animationPlayer.play(anims[selectedPos])


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	await get_tree().create_timer(5).timeout
	queue_free()

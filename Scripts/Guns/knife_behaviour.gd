extends Node3D
class_name Knife

@onready var animationPlayer : AnimationPlayer = $HandKnife/Player_Arms/AnimationPlayer
@onready var collisionShape : CollisionShape3D = $HandKnife/knife/Area3D/CollisionShape3D
@onready var knifeRigidBody : RigidBody3D = $HandKnife/knife/Area3D
@export var handsNode := NodePath()
@onready var hands : Node3D = get_node(handsNode)

signal endedMelee

# Called when the node enters the scene tree for the first time.
func _ready():
	collisionShape.disabled = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Knife_Shot":
		endedMelee.emit()

func _on_area_3d_body_entered(body):

	if body is Target:
		body.targetData.actualHealth = 0

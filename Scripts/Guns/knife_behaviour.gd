extends Node3D

@onready var animationPlayer : AnimationPlayer = $HandKnife/Player_Arms/AnimationPlayer

@export var handsNode := NodePath()
@onready var hands : Node3D = get_node(handsNode)

signal endedMelee

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Knife_Shot":
		endedMelee.emit()

class_name HitIndicator
extends Control

@onready var animationPlayer : AnimationPlayer = $AnimationPlayer
@onready var indicator_node = $Screen_centered/Damage_Indicator


signal finished(node)

var instigator : Player
# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "hit_anim":
		finished.emit(self)

class_name HitIndicator
extends Control

@onready var animationPlayer : AnimationPlayer = $AnimationPlayer
@onready var indicator_node = $Screen_centered/Damage_Indicator

var instigator : Player
# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

class_name HitIndicator
extends Control

@onready var animationPlayer : AnimationPlayer = $AnimationPlayer

var instigator : Player
# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

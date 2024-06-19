class_name FiringRange_NPC extends Node3D

@onready var animationPlayer : AnimationPlayer = $"../../../../AnimationPlayer"
@export var npcData : NPCData

var player : Player
# Called when the node enters the scene tree for the first time.
func _ready():
	animationPlayer.play("Idle")

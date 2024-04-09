extends Node3D

@export var animationNode := NodePath()
@onready var animationPlayer : AnimationPlayer = get_node(animationNode)



# Called when the node enters the scene tree for the first time.
func _ready():
	#animationPlayer.play("Idle_Pistol_OneHand")+ç
	pass


func _physics_process(delta):
	pass

class_name Bullet
extends RigidBody3D

signal hitmark

@onready var collider : CollisionShape3D = $CollisionShape3D
@export var meshNode := NodePath()
@onready var mesh : MeshInstance3D = get_node(meshNode)
var damage : float

# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().create_timer(2).timeout
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_visibility_notifier_screen_exited():
	queue_free()

func _on_body_entered(body):
	if body is Target and not body.isDowned:
		body.targetData.actualHealth -= damage
		hitmark.emit()
		queue_free()


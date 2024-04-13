extends RigidBody3D

@onready var collider : CollisionShape3D = $CollisionShape3D
@export var meshNode := NodePath()
@onready var mesh : MeshInstance3D = get_node(meshNode)

# Called when the node enters the scene tree for the first time.
func _ready():
	$CollisionShape3D.disabled = true
	await get_tree().create_timer(0.3).timeout
	$CollisionShape3D.disabled = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_visibility_notifier_screen_exited():
	queue_free()

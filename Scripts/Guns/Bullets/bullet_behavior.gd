class_name Bullet
extends RigidBody3D

signal hitmark
signal playerDamaged

signal kill

@onready var impactParticle: CPUParticles3D = $CPUParticles3D
@onready var collider : CollisionShape3D = $CollisionShape3D
@export var meshNode := NodePath()
@onready var mesh : MeshInstance3D = get_node(meshNode)

var instigator: CharacterBody3D

var damage : float
var distanceTraveled: float = 0
var decal_instance : Decal

@export var decal : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	lock_rotation = true
	await get_tree().create_timer(15).timeout
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	distanceTraveled += 0.005
	pass

func _on_visibility_notifier_screen_exited():
	queue_free()

func _on_body_entered(body: Node3D):
	mesh.visible = false
	freeze = true
	
	spawn_decal(body)
	
	if body is Target and not body.isDowned:
		body.targetData.actualHealth -= damage - distanceTraveled
		if body.targetData.actualHealth <= 0:
			kill.emit()
		
		hitmark.emit()
		impactParticle.emitting = true
	
	if body is Player:
		body.health -= damage
		playerDamaged.emit()
	
	var fade_tween: Tween = get_tree().create_tween()
	fade_tween.tween_interval(2.0)
	fade_tween.tween_property(decal_instance, "modulate:a", 0, 1.5)
	await fade_tween.finished
	decal_instance.queue_free()
	queue_free()

func spawn_decal(body : Node3D):
	decal_instance = decal.instantiate()
	get_tree().root.add_child(decal_instance)
	decal_instance.global_position = position
	decal_instance.look_at(decal_instance.transform.origin + body.global_position.normalized(), Vector3.UP)
	decal_instance.rotate_object_local(Vector3(0,1,0), randf_range(0.0,360.0))

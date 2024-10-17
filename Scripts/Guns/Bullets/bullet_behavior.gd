class_name Bullet
extends RigidBody3D

signal hitmark(hitPoints)
signal playerDamaged

signal kill(points)

@onready var impactParticle: GPUParticles3D = $CPUParticles3D
@onready var collider : CollisionShape3D = $CollisionShape3D
@export var meshNode := NodePath()
@onready var mesh : MeshInstance3D = get_node(meshNode) 
@onready var trail : Trail3D = $Trail3D2

var instigator: Player

var damage : float
var distanceTraveled: float = 0
var decal_instance : Decal

@export var decal : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().create_timer(5).timeout
	
	queue_free()
	#disable trail effect for players, it is intended to be only seen from enemies who shoot at you
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	distanceTraveled += 0.0001
	for collision in get_colliding_bodies():
		if collision.is_class("Target") or (collision.is_class("Player") and collision != instigator):
			_on_area_3d_body_entered(collision)

func spawn_decal(body : Node3D):
	decal_instance = decal.instantiate()
	get_tree().root.add_child(decal_instance)
	if !body.global_position.normalized().is_equal_approx(Vector3.UP) and !body.global_position.normalized().is_equal_approx(Vector3.DOWN):
		decal_instance.look_at(decal_instance.global_transform.origin + body.global_position.normalized(), Vector3.UP)
		decal_instance.rotate_object_local(Vector3(1,0,0), 90)


func _on_area_3d_body_entered(body : Node3D):
	print("cuerpo detectado")
	mesh.visible = false
	#spawn_decal(body)
	if body is Target and body != self and not body.isDowned:
		body.targetData.actualHealth -= damage - distanceTraveled
		impactParticle.emitting = true
		if instigator.hud.animationPlayer.is_playing():
			instigator.hud.animationPlayer.play("RESET")
		instigator.hud.animationPlayer.play("hitmarker")
		
		queue_free()
	
	if body.is_class("Player"): #and body != instigator:
		var playerHit : Player = body.get_parent()
		var audioSteam : AudioStream = load("res://GameResources/Sounds/Misc/hitmarker_sound.wav")
		SFXHandler.play_sfx(audioSteam, instigator, "Effects")
		playerHit.health -= damage - distanceTraveled
		playerDamaged.emit()
		if instigator.hud.animationPlayer.is_playing():
			instigator.hud.animationPlayer.play("RESET")
		instigator.hud.animationPlayer.play("hitmarker")
		
		playerHit.assign_enemy_to_player_hit.rpc_id(playerHit.name.to_int(), instigator.name.to_int(), playerHit.name.to_int())
		if playerHit.health <= 0 and playerHit.visible == true:
			instigator.hud.killPointsAnimPlayer.play("killNotification")
			playerHit.die_respawn.rpc(playerHit.name.to_int(), instigator.name.to_int())
	
		queue_free()
	
	#var fade_tween: Tween = get_tree().create_tween()
	#fade_tween.tween_interval(2.0)
	#fade_tween.tween_property(decal_instance, "modulate:a", 0, 1.5)
	#await fade_tween.finished
	#decal_instance.queue_free()
	queue_free()


func _on_area_3d_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	if body.is_class("Bullet"):
		return
	else:
		_on_area_3d_body_entered(body)

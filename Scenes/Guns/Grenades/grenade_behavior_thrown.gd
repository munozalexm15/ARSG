class_name GrenadeThrown
extends RigidBody3D

@onready var detonationTimer : Timer = $DetonationTime
@onready var greandeMeshParent : Node3D = $grenade
@onready var explosionArea : Area3D = $Area3D
@onready var damageArea : Area3D = $DamageArea
@onready var explosionParticleParent : Node3D = $ParticlesGrenade
@onready var hit_decal : Decal = $Decal
@onready var bounceAudio : AudioStreamPlayer3D = $BounceAudio3D
@onready var explodeAudio : AudioStreamPlayer3D = $ExplosionAudio3D
var instigator_id = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
func _process(delta: float) -> void:
	
	var collisions : Array = get_colliding_bodies()
	if collisions.size() > 0 and not bounceAudio.playing and linear_velocity.length() >= 1:
		bounceAudio.play()
		
#debe ser algo con un rpc
func _on_detonation_time_timeout() -> void:
	checkExplosionEffect.rpc()

@rpc("any_peer", "call_local", "reliable")
func checkExplosionEffect():
	explodeAudio.play()
	
	lock_rotation = true
	rotation = Vector3.ZERO
	var bodies = explosionArea.get_overlapping_bodies()
	
	#camera shake
	for body in bodies:
		var space = get_world_3d().direct_space_state
		var a : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()
		a.from = global_transform.origin
		a.to = body.global_transform.origin
			
		
		if body is Player:
			var distanceStrength = a.to.distance_to(global_transform.origin)
			if distanceStrength <= 5:
				distanceStrength = distanceStrength / 30
			elif distanceStrength > 5:
				distanceStrength = distanceStrength / 500
			body.camera.randomStrength = distanceStrength
			body.camera.apply_camera_shake()
		
		var collision = space.intersect_ray(a)
		
	bodies = damageArea.get_overlapping_bodies()
	
	#damage
	for body in bodies:
		var space = get_world_3d().direct_space_state
		var a : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()
		a.from = global_transform.origin
		a.to = body.global_transform.origin
		var collision = space.intersect_ray(a)
		 
		if collision.collider is Player:
			collision.collider.assign_enemy_to_player_hit.rpc(collision.collider.name.to_int(), collision.collider.name.to_int())
			var distanceStrength = a.to.distance_to(global_transform.origin)
			if distanceStrength <= 2:
				collision.collider.health -= distanceStrength * 120
			if distanceStrength > 2 and distanceStrength <= 5:
				collision.collider.health -= distanceStrength * 20
			
			if body.health <= 0 and body.visible == true:
				collision.collider.die_respawn.rpc(collision.collider.name.to_int(), instigator_id, "grenade")
	
	for child : GPUParticles3D in explosionParticleParent.get_children():
		child.emitting = true
	greandeMeshParent.visible = false
	hit_decal.visible = true

func _on_s_moke_finished() -> void:
	var fade_tween: Tween = get_tree().create_tween()
	fade_tween.tween_interval(1.0)
	fade_tween.tween_property(hit_decal, "modulate:a", 0, 1.5)
	await fade_tween.finished
	queue_free()

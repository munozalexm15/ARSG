extends Node3D


signal hitmark(hitPoints)
signal playerDamaged

signal kill(points)

@onready var ray : RayCast3D = $RayCast3D

var SPEED = 10.0

var instigator : Player 

var damage : float
var distanceTraveled: float = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().create_timer(5.0).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	if not ray.enabled:
		return
	
	distanceTraveled += 0.0001
	position += transform.basis * Vector3(0,0,-SPEED)
	if ray.is_colliding():
		ray.enabled = false
		_on_area_3d_body_entered(ray.get_collider())

func _on_area_3d_body_entered(body : Node3D):
	
	#spawn_decal(body)
	$MeshInstance3D.visible = false

	if body.get_parent().get_parent() is FloatingHead:
		var floatingHead : FloatingHead = body.get_parent().get_parent()
		SFXHandler.play_sfx(floatingHead.noisesArray.pick_random(), floatingHead, "Effects")
	
	
	if body is Target and body != self and not body.isDowned:
		body.targetData.actualHealth -= damage - distanceTraveled
		if instigator.hud.animationPlayer.is_playing():
			instigator.hud.animationPlayer.play("RESET")
		instigator.hud.animationPlayer.play("hitmarker")
		var audioSteam : AudioStream = load("res://GameResources/Sounds/Misc/hitmarker_sound.wav")
		SFXHandler.play_sfx(audioSteam, instigator, "Effects")
	
	if body is Player and body != instigator:
		var audioSteam : AudioStream = load("res://GameResources/Sounds/Misc/hitmarker_sound.wav")
		SFXHandler.play_sfx(audioSteam, instigator, "Effects")
		body.health -= damage - distanceTraveled
		playerDamaged.emit()
		if instigator.hud.animationPlayer.is_playing():
			instigator.hud.animationPlayer.play("RESET")
		instigator.hud.animationPlayer.play("hitmarker")
		
		body.assign_enemy_to_player_hit.rpc_id(body.name.to_int(), instigator.name.to_int(), body.name.to_int())
		if body.health <= 0 and body.visible == true:
			instigator.hud.killPointsAnimPlayer.play("killNotification")
			body.die_respawn.rpc(body.name.to_int(), instigator.name.to_int())
		

	
	if body is StaticBody3D or body is not Player:
		var decal = BulletDecalPool.spawn_bullet_decal(ray.get_collision_point(), ray.get_collision_normal(), body, ray.global_basis)
		
		var fade_tween: Tween = get_tree().create_tween()
		fade_tween.tween_interval(2.0)
		fade_tween.tween_property(decal, "modulate:a", 0, 1.5)
		await fade_tween.finished
	
	$MeshInstance3D.visible = false
	

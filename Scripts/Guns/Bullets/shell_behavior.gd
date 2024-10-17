extends Node3D


signal hitmark(hitPoints)
signal playerDamaged

signal kill(points)

@onready var ray : RayCast3D = $RayCast3D

var SPEED = 10.0

var instigator : Player 

var damage : float
var distanceTraveled: float = 0
var decal_instance : Decal
var ready_to_move = false

# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().process_frame
	ready_to_move = true
	await get_tree().create_timer(5).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	distanceTraveled += 0.0001
	if ready_to_move:
		position += transform.basis * Vector3(0,0,-SPEED)
		if ray.is_colliding():
			_on_area_3d_body_entered(ray.get_collider())

func _on_area_3d_body_entered(body : Node3D):
	print(body.name)
	#spawn_decal(body)
	if body is Target and body != self and not body.isDowned:
		body.targetData.actualHealth -= damage - distanceTraveled
		if instigator.hud.animationPlayer.is_playing():
			instigator.hud.animationPlayer.play("RESET")
		instigator.hud.animationPlayer.play("hitmarker")
		var audioSteam : AudioStream = load("res://GameResources/Sounds/Misc/hitmarker_sound.wav")
		SFXHandler.play_sfx(audioSteam, instigator, "Effects")
		
		queue_free()
	
	if body is Player:# and body != instigator:
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

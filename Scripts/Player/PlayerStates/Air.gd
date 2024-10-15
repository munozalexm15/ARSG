# Air.gd
extends PlayerState

var falling_velocity = 0.0
# If we get a message asking us to jump, we jump.
func enter(msg := {}) -> void:
	if msg.has("jump"):
		player.player_body.animationTree.set("parameters/Movement/transition_request", "Idle_Jump")
		if not player.player_body.animationTree.is_connected("animation_finished", body_animation_ended):
			player.player_body.animationTree.connect("animation_finished", body_animation_ended)
		
		player.velocity.y = player.jump_force
	else:
		player.player_body.animationTree.set("parameters/Movement/transition_request", "Air_Falling")
	
	if msg.has("climb"):
		#(player.velocity += Vector3(0, player.jump_force * 4, 0)
		pass

	player.standing_CollisionShape.disabled = false
	player.crouching_CollisionShape.disabled = true
	
func physics_update(delta: float) -> void:
	if player.arms.animationPlayer.current_animation == null:
		player.arms.animationPlayer.play("Idle")
		
	if player.direction:
		player.velocity.x = player.direction.x * player.curr_speed
		player.velocity.z = player.direction.z * player.curr_speed
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, player.curr_speed)
		player.velocity.z = move_toward(player.velocity.z, 0, player.curr_speed)
	
	if not player.is_on_floor():
		player.velocity.y -= player.gravity * delta
		falling_velocity = player.velocity.y
	
	if player.is_on_floor() and player.input_direction.x != 0:
		#if falling_velocity < -5:
			#player.animationPlayer.play("hard_landing")
		#elif falling_velocity >= -5:
			#player.animationPlayer.play("soft_landing")
		
		state_machine.transition_to("Walk")
	
	elif player.is_on_floor() and player.input_direction.x == 0:
		#if falling_velocity < -5:
			#player.animationPlayer.play("hard_landing")
		#elif falling_velocity >= -5:
			#player.animationPlayer.play("soft_landing")
		state_machine.transition_to("Idle")

func body_animation_ended(anim_name):
	if anim_name == "Idle_Jump":
		player.player_body.animationTree.set("parameters/Movement/transition_request", "Air_Falling")

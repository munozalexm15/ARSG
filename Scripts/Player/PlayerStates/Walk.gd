extends PlayerState

func enter(_msg := {}):
	player.curr_speed = player.walk_speed
	player.headBobbing_curr_intensity = player.hb_intensities.get("walk_speed")
	
	if player.arms.animationPlayer.assigned_animation != "Idle" and player.arms.state_machine.state.name == "Idle":
		player.arms.animationPlayer.play("Idle")

func physics_update(delta: float) -> void:
	
	#En un futuro estructurar mejor
	#play_anim.rpc()
	
	if not Input.is_action_pressed("ADS"):
		player.curr_speed = player.walk_speed
		player.headBobbing_curr_intensity = player.hb_intensities.get("walk_speed")
		player.headBobbing_index += player.hb_speeds.get("walk_speed") * delta
	else:
		player.curr_speed = player.crouch_speed
		player.headBobbing_curr_intensity = player.hb_intensities.get("crouch_speed")
		player.headBobbing_index += player.hb_speeds.get("crouch_speed") * delta
	
	if player.direction != Vector3.ZERO:
		player.velocity.x = player.direction.x * player.curr_speed
		player.velocity.z = player.direction.z * player.curr_speed
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, player.curr_speed)
		player.velocity.z = move_toward(player.velocity.z, 0, player.curr_speed)
		
	if player.input_direction == Vector2.ZERO:
		state_machine.transition_to("Idle")
	
	if not player.is_on_floor():
		state_machine.transition_to("Air")
		
	if Input.is_action_just_pressed("Jump"):
		state_machine.transition_to("Air", {jump = true})
	
	if player.arms.state_machine.state.name != "Melee":
		if (player.direction.x != 0 or player.direction.z != 0) and player.is_on_floor() and Input.is_action_just_pressed("Sprint") and not Input.is_action_pressed("ADS") :
			state_machine.transition_to("Run")
	
	if Input.is_action_just_pressed("Crouch"):
		state_machine.transition_to("Crouch")
	
	player.move_and_slide()

@rpc("call_local", "any_peer")
func play_anim():
	if Input.is_action_pressed("Backwards"):
		player.player_body.animationPlayer.play("Player_Pistol_Backwards_Aim_Walk", -1, 4, false)
	if Input.is_action_pressed("Forward"):
		player.player_body.animationPlayer.play("Player_Pistol_Forward_Aim_Walk", -1, 4, false)
	if Input.is_action_pressed("Left"):
		player.player_body.animationPlayer.play("Player_Pistol_Left_Aim_Walk", -1, 4, false)
	if Input.is_action_pressed("Right"):
		player.player_body.animationPlayer.play("Player_Pistol_Right_Aim_Walk", -1, 4, false)


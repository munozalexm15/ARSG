extends PlayerState

# Called when the node enters the scene tree for the first time.
func enter(_msg := {}):
	if player.state_machine.old_state.name == "Air":
		player.player_body.animationPlayer.play("Air_Land")
		
	player.curr_speed = player.run_speed
	if not player.arms.state_machine.state.name == "Reload":
		player.arms.animationPlayer.play("Run")

func _input(_event):
	if Input.is_action_just_pressed("ADS") and not Input.is_action_pressed("Crouch") and !player.standingRaycast.is_colliding():
		state_machine.transition_to("Walk")

func physics_update(delta: float):
	if Input.is_action_just_pressed("Fire"):
		state_machine.transition_to("Walk")
	
	play_anim.rpc()

	player.headBobbing_curr_intensity = player.hb_intensities.get("sprint_speed")
	player.headBobbing_index += player.hb_speeds.get("sprint_speed") * delta
	
	if player.direction != Vector3.ZERO:
		player.velocity.x = player.direction.x * player.curr_speed
		player.velocity.z = player.direction.z * player.curr_speed
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, player.curr_speed)
		player.velocity.z = move_toward(player.velocity.z, 0, player.curr_speed)
		
	if not player.is_on_floor():
		state_machine.transition_to("Air")
		
	if Input.is_action_just_pressed("Jump"):
		state_machine.transition_to("Air", {jump = true})

	if player.arms.state_machine.state.name != "Melee":
		if (player.direction.x != 0 or player.direction.z != 0) and player.is_on_floor() and (Input.is_action_just_released("Sprint") or Input.is_action_just_pressed("Fire")):
			state_machine.transition_to("Walk")
	
	if player.input_direction.x == 0 and player.input_direction.y == 0:
		state_machine.transition_to("Idle")
	
	if Input.is_action_pressed("Crouch"):
		state_machine.transition_to("Crouch")


@rpc("call_local", "any_peer")
func play_anim():
	#Just backwards
	if Input.is_action_pressed("Backwards") and (not Input.is_action_pressed("Left") or not Input.is_action_pressed("Right")):
		player.player_body.animationPlayer.play("Run_Backwards", -1, 1, false)
	#Just forward
	if Input.is_action_pressed("Forward") and (not Input.is_action_pressed("Left") or not Input.is_action_pressed("Right")):
		player.player_body.animationPlayer.play("Run_Forward", -1, 1, false)
	
	if Input.is_action_pressed("Left"):
		player.player_body.animationPlayer.play("Run_Left", -1, 1, false)
	
	if Input.is_action_pressed("Right"):
		player.player_body.animationPlayer.play("Run_Right", -1, 1, false)
	
	#Backwards left
	if Input.is_action_pressed("Backwards") and Input.is_action_pressed("Left") and (not Input.is_action_pressed("Right")):
		player.player_body.animationPlayer.play("Run_BackwardsLeft", -1, 1, false)
	#Backwards right
	elif Input.is_action_pressed("Backwards") and Input.is_action_pressed("Right") and (not Input.is_action_pressed("Left")):
		player.player_body.animationPlayer.play("Run_BackwardsRight", -1, 1, false)

	if Input.is_action_pressed("Forward") and Input.is_action_pressed("Left") and (not Input.is_action_pressed("Right")):
		player.player_body.animationPlayer.play("Run_ForwardLeft", -1, 1, false)
	
	elif Input.is_action_pressed("Forward") and Input.is_action_pressed("Right") and (not Input.is_action_pressed("Left")):
		player.player_body.animationPlayer.play("Run_ForwardRight", -1, 1, false)

func exit():
	if not player.arms.state_machine.state.name == "Reload":
		player.arms.animationPlayer.play("Idle")

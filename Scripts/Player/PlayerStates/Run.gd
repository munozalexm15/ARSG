extends PlayerState

# Called when the node enters the scene tree for the first time.
func enter(_msg := {}):
	player.curr_speed = player.run_speed
	
	

func physics_update(delta: float):
	player.headBobbing_curr_intensity = player.hb_intensities.get("sprint_speed")
	player.headBobbing_index += player.hb_intensities.get("sprint_speed") * delta
	
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

	if (player.direction.x != 0 or player.direction.z != 0) and player.is_on_floor() and Input.is_action_just_released("Sprint"):
		state_machine.transition_to("Walk")
	
	if Input.is_action_just_pressed("Crouch"):
		state_machine.transition_to("Crouch")


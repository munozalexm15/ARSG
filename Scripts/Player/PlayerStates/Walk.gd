extends PlayerState

func enter(_msg := {}):
	player.curr_speed = player.walk_speed

func physics_update(delta: float) -> void:
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
	
	if (player.direction.x != 0 or player.direction.z != 0) and player.is_on_floor() and Input.is_action_just_pressed("Sprint"):
		state_machine.transition_to("Run")
	
	if Input.is_action_just_pressed("Crouch"):
		state_machine.transition_to("Crouch")
	
	player.move_and_slide()

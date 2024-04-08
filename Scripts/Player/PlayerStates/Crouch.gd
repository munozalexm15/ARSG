extends PlayerState

func enter(_msg := {}):
	player.curr_speed = player.crouch_speed
	

func physics_update(delta: float) -> void:
	player.head.position.y = lerp(player.head.position.y, player.initialHead_pos- player.crouching_depth, delta * player.lerp_speed)
	if player.direction != Vector3.ZERO:
		player.velocity.x = player.direction.x * player.curr_speed
		player.velocity.z = player.direction.z * player.curr_speed
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, player.curr_speed)
		player.velocity.z = move_toward(player.velocity.z, 0, player.curr_speed)
		
	if not player.is_on_floor():
		state_machine.transition_to("Air")
		
	if Input.is_action_just_pressed("Jump"):
		state_machine.transition_to("Air", {"jump" = true})
	
	if (player.direction.x != 0 or player.direction.z != 0) and player.is_on_floor() and Input.is_action_pressed("Sprint"):
		state_machine.transition_to("Run")
	
	if Input.is_action_just_released("Crouch") and player.input_direction != Vector2.ZERO:
		state_machine.transition_to("Walk")
	elif Input.is_action_just_released("Crouch") and player.input_direction == Vector2.ZERO:
		state_machine.transition_to("Idle")
	
	player.move_and_slide()


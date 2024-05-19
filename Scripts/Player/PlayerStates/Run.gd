extends PlayerState

# Called when the node enters the scene tree for the first time.
func enter(_msg := {}):
	player.curr_speed = player.run_speed
	if not player.arms.state_machine.state.name == "Reload":
		player.arms.animationPlayer.play("Run")

func _input(event):
	if Input.is_action_just_pressed("ADS") and not Input.is_action_pressed("Crouch") and !player.standingRaycast.is_colliding():
		state_machine.transition_to("Walk")

func physics_update(delta: float):
	if Input.is_action_just_pressed("Fire"):
		state_machine.transition_to("Walk")


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

func exit():
	if not player.arms.state_machine.state.name == "Reload":
		player.arms.animationPlayer.play("Idle")

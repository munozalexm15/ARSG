extends PlayerState

func enter(_msg := {}):
	player.curr_speed = player.walk_speed
	player.headBobbing_curr_intensity = player.hb_intensities.get("walk_speed")
	
	if player.state_machine.old_state.name == "Air":
		player.player_body.animationTree.set("parameters/Movement/transition_request", "Air_Land")
	
	if player.arms.animationPlayer.assigned_animation != "Idle" and player.arms.state_machine.state.name == "Idle":
		player.arms.animationPlayer.play("Idle")
		
	player.standing_CollisionShape.disabled = false
	player.crouching_CollisionShape.disabled = true

func physics_update(delta: float) -> void:
	#En un futuro estructurar mejor
	play_anim.rpc()
	
	if not Input.is_action_pressed("ADS") or (Input.is_action_pressed("ADS") and player.arms.state_machine.state.name == "Reload"):
		player.curr_speed = player.walk_speed
		player.headBobbing_curr_intensity = player.hb_intensities.get("walk_speed")
		player.headBobbing_index += player.hb_speeds.get("walk_speed") * delta
	else:
		#añadida comprobación adicional para evitar que se pare de golpe (cuando esta andando unicamente)
		if player.state_machine.old_state.name != "Air" or player.is_on_floor():
			player.curr_speed = player.crouch_speed
			player.headBobbing_curr_intensity = player.hb_intensities.get("crouch_speed")
			player.headBobbing_index += player.hb_speeds.get("crouch_speed") * delta
	
	if not player.isPauseMenuOpened:
		if not Network.game.chatText.has_focus():
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
		if player.isPauseMenuOpened or Network.game.chatText.has_focus():
			return
		state_machine.transition_to("Air", {jump = true})
	
	if player.arms.state_machine.state.name != "Melee":
		if player.input_direction.y <= -0.7 and player.is_on_floor() and Input.is_action_just_pressed("Sprint") and not Input.is_action_pressed("ADS") :
			state_machine.transition_to("Run")
	
	if Input.is_action_just_pressed("Crouch") and (not player.isPauseMenuOpened or not Network.game.chatText.has_focus()):
		state_machine.transition_to("Crouch")
	
	player.move_and_slide()

@rpc("call_local", "any_peer")
func play_anim():
	var walk_type = "Walk"
	if Input.is_action_pressed("ADS"):
		walk_type = "Aim"
	
	#Just backwards
	if Input.is_action_pressed("Backwards") and (not Input.is_action_pressed("Left") or not Input.is_action_pressed("Right")):
		player.player_body.animationTree.set("parameters/Movement/transition_request", walk_type + "_Backwards")
		
	#Just forward
	if Input.is_action_pressed("Forward") and (not Input.is_action_pressed("Left") or not Input.is_action_pressed("Right")):
		player.player_body.animationTree.set("parameters/Movement/transition_request", walk_type + "_Forward")
		
	if Input.is_action_pressed("Left"):
		player.player_body.animationTree.set("parameters/Movement/transition_request", walk_type + "_Left")
		
	if Input.is_action_pressed("Right"):
		player.player_body.animationTree.set("parameters/Movement/transition_request", walk_type + "_Right")
		
	#Backwards left
	if Input.is_action_pressed("Backwards") and Input.is_action_pressed("Left") and (not Input.is_action_pressed("Right")):
		player.player_body.animationTree.set("parameters/Movement/transition_request", walk_type + "_BackwardsLeft")
	
	#Backwards right
	elif Input.is_action_pressed("Backwards") and Input.is_action_pressed("Right") and (not Input.is_action_pressed("Left")):
		player.player_body.animationTree.set("parameters/Movement/transition_request", walk_type + "_BackwardsRight")
	
	if Input.is_action_pressed("Forward") and Input.is_action_pressed("Left") and (not Input.is_action_pressed("Right")):
		player.player_body.animationTree.set("parameters/Movement/transition_request", walk_type + "_ForwardLeft")
		
	elif Input.is_action_pressed("Forward") and Input.is_action_pressed("Right") and (not Input.is_action_pressed("Left")):
		player.player_body.animationTree.set("parameters/Movement/transition_request", walk_type + "_ForwardRight")
		

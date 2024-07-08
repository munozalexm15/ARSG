extends PlayerState

var slide_timer = 0.0
var slide_duration = 1
var slide_vector = Vector2.ZERO

var slide_multiplier = 10.0

var canRun = false

func enter(_msg := {}):
	player.player_body.animationPlayer.play("Crouch_Idle", -1, 1, false)
	player.curr_speed = player.crouch_speed
	player.crouching_CollisionShape.disabled = false
	player.standing_CollisionShape.disabled = true
	player.curr_speed = player.crouch_speed

#Slide Mechanic
	#if state_machine.old_state.name == "Run" and player.input_direction != Vector2.ZERO:
		#slide_timer = slide_duration
		#slide_vector = player.input_direction
		

func physics_update(delta: float) -> void:
#Slide mechanic -- WIP 
#---------------------------------------------
	#if state_machine.old_state.name == "Run" and player.input_direction != Vector2.ZERO and slide_timer > 0:
		#slide_timer -= delta
		#player.direction = player.transform.basis * Vector3(slide_vector.x, 0, slide_vector.y).normalized()
		#if slide_timer <= 0:
			#player.curr_speed = player.crouch_speed
#---------------------------------------------

	player.headBobbing_curr_intensity = player.hb_intensities.get("crouch_speed")
	player.headBobbing_index += player.hb_speeds.get("crouch_speed") * delta
	player.eyes.position.y = lerp(player.eyes.position.y, player.initialHead_pos- player.crouching_depth, delta * player.lerp_speed)
	player.arms.position.y = lerp(player.arms.position.y, player.initialHands_pos + player.crouching_depth / 2, delta * player.lerp_speed)
	
	if player.direction != Vector3.ZERO and player.input_direction != Vector2.ZERO:
		play_anim.rpc()
		player.velocity.x = player.direction.x * player.curr_speed
		player.velocity.z = player.direction.z * player.curr_speed
		 
		if state_machine.old_state.name == "Run" and slide_timer > 0.1:
			player.velocity.x = player.direction.x * slide_timer * slide_multiplier
			player.velocity.z = player.direction.z * slide_timer * slide_multiplier
	
	if Vector2.ZERO == player.input_direction:
		player.velocity.x = move_toward(player.velocity.x, 0.0, player.curr_speed)
		player.velocity.z = move_toward(player.velocity.z, 0.0, player.curr_speed)
		player.player_body.animationPlayer.play("Crouch_Idle", -1, 1, false)
		
	if not player.is_on_floor():
		state_machine.transition_to("Air")
		
	if Input.is_action_just_pressed("Jump") and !player.standingRaycast.is_colliding():
		state_machine.transition_to("Air", {"jump" = true})
	
	if (!Input.is_action_pressed("Crouch")) and !player.standingRaycast.is_colliding() and player.input_direction != Vector2.ZERO:
		
		player.crouching_CollisionShape.disabled = true
		player.standing_CollisionShape.disabled = false
		state_machine.transition_to("Walk")
		
	elif !Input.is_action_pressed("Crouch") and !player.standingRaycast.is_colliding() and player.input_direction == Vector2.ZERO:
		player.crouching_CollisionShape.disabled = true
		player.standing_CollisionShape.disabled = false
		state_machine.transition_to("Idle")
	
	player.move_and_slide()

func exit():
	player.crouching_CollisionShape.disabled = true
	player.standing_CollisionShape.disabled = false

@rpc("call_local", "any_peer")
func play_anim():
	var walk_type = "Crouch"
	#Just backwards
	if Input.is_action_pressed("Backwards") and (not Input.is_action_pressed("Left") or not Input.is_action_pressed("Right")):
		player.player_body.animationPlayer.play(walk_type + "_Backwards", -1, 1, false)
	#Just forward
	if Input.is_action_pressed("Forward") and (not Input.is_action_pressed("Left") or not Input.is_action_pressed("Right")):
		player.player_body.animationPlayer.play(walk_type + "_Forward", -1, 1, false)
	
	if Input.is_action_pressed("Left"):
		player.player_body.animationPlayer.play(walk_type + "_Left", -1, 1, false)
	
	if Input.is_action_pressed("Right"):
		player.player_body.animationPlayer.play(walk_type + "_Right", -1, 1, false)
	
	#Backwards left
	if Input.is_action_pressed("Backwards") and Input.is_action_pressed("Left") and (not Input.is_action_pressed("Right")):
		player.player_body.animationPlayer.play(walk_type + "_BackwardsLeft", -1, 1, false)
	#Backwards right
	elif Input.is_action_pressed("Backwards") and Input.is_action_pressed("Right") and (not Input.is_action_pressed("Left")):
		player.player_body.animationPlayer.play(walk_type + "_BackwardsRight", -1, 1, false)

	if Input.is_action_pressed("Forward") and Input.is_action_pressed("Left") and (not Input.is_action_pressed("Right")):
		player.player_body.animationPlayer.play(walk_type + "_ForwardLeft", -1, 1, false)
	
	elif Input.is_action_pressed("Forward") and Input.is_action_pressed("Right") and (not Input.is_action_pressed("Left")):
		player.player_body.animationPlayer.play(walk_type + "_ForwardRight", -1, 1, false)
	

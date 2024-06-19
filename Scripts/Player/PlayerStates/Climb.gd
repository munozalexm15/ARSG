extends PlayerState

# Called when the node enters the scene tree for the first time.
func enter(_msg := {}):
	player.isClimbing = true
	player.gravity = 0
	player.velocity = Vector3.ZERO
	player.direction = Vector3.ZERO

func _physics_update(delta):
	
	player.headBobbing_index += player.hb_speeds.get("idle_speed") * delta

func update(_delta: float):
	if !player.isClimbing and !player.is_on_floor():
		state_machine.transition_to("Air", {"climb" = true})
	
	if player.is_on_floor():
		state_machine.transition_to("Idle")
	
	if Input.is_action_just_pressed("Jump"):
		state_machine.transition_to("Air", {"jump" = true, "backwards" = true})
	
	if Input.is_action_pressed("Forward"):
		player.velocity.y = player.jump_force
		player.direction = Vector3.UP
	
	if Input.is_action_pressed("Backwards"):
		player.velocity.y = player.jump_force * -1
		player.direction = Vector3.DOWN
	
	if player.input_direction == Vector2.ZERO:
		player.velocity = Vector3.ZERO
		player.direction = Vector3.ZERO

func exit():
	player.isClimbing = false
	player.gravity = player.defaultGravity
	player.velocity = Vector3.FORWARD
	player.direction = Vector3.FORWARD
	#timer for preventing entering climbing state again
	await get_tree().create_timer(1).timeout

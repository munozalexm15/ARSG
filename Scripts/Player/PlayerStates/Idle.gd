extends PlayerState

# Called when the node enters the scene tree for the first time.
func enter(_msg := {}):
	player.velocity = Vector3.ZERO
	player.direction = Vector3.ZERO

func update(delta: float):
	if not player.is_on_floor():
		state_machine.transition_to("Air")
		
	if Input.is_action_just_pressed("Jump"):
		state_machine.transition_to("Air", {"jump" = true})

	if (player.direction.x != 0 or player.direction.z != 0) and player.is_on_floor():
		state_machine.transition_to("Walk")
	
	if Input.is_action_pressed("Crouch"):
		state_machine.transition_to("Crouch")

	if Input.is_action_just_pressed("Sprint"):
		state_machine.transition_to("Run")

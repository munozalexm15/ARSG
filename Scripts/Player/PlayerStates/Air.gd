# Air.gd
extends PlayerState

var falling_velocity = 0.0
# If we get a message asking us to jump, we jump.
func enter(msg := {}) -> void:
	if msg.has("jump"):
		player.velocity.y = player.jump_force
	

func physics_update(delta: float) -> void:
	if player.direction:
		player.velocity.x = player.direction.x * player.curr_speed
		player.velocity.z = player.direction.z * player.curr_speed
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, player.curr_speed)
		player.velocity.z = move_toward(player.velocity.z, 0, player.curr_speed)
	
	if not player.is_on_floor():
		player.velocity.y -= player.gravity * delta
		falling_velocity = player.velocity.y
	if player.is_on_floor() and player.input_direction.x != 0:
		if falling_velocity < -5:
			player.animationPlayer.play("hard_landing")
		elif falling_velocity >= -5:
			player.animationPlayer.play("soft_landing")
		state_machine.transition_to("Walk")
	
	elif player.is_on_floor() and player.input_direction.x == 0:
		if falling_velocity < -5:
			player.animationPlayer.play("hard_landing")
		elif falling_velocity >= -5:
			player.animationPlayer.play("soft_landing")
		state_machine.transition_to("Idle")

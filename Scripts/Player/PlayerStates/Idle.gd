extends PlayerState

var last_rotation_horizontal = 0.0
var rotation_value = 0

@onready var eyesHolder : Node3D = $"../../Head/eyesHolder"

# Called when the node enters the scene tree for the first time.
func enter(_msg := {}):
	if not is_multiplayer_authority():
		return
	
	if player.state_machine.old_state.name == "Air":
		player.player_body.animationTree.set("parameters/Movement/transition_request", "Air_Land")
	else:
		player.player_body.animationTree.set("parameters/Movement/transition_request", "Idle")
	player.velocity = Vector3.ZERO
	player.direction = Vector3.ZERO
	player.headBobbing_curr_intensity = player.hb_intensities.get("idle_speed")

func physics_update(delta):
	if not is_multiplayer_authority():
		return
	player.headBobbing_index += player.hb_speeds.get("idle_speed") * delta

func update(_delta: float):
	
	if not is_multiplayer_authority():
		return
	if int(player.rotation.y) < rotation_value:
		rotation_value = int(player.rotation.y)
		player.player_body.animationTree.set("parameters/Movement/transition_request", "Idle_TurnRight")
	elif int(player.rotation.y) > rotation_value:
		rotation_value = int(player.rotation.y)
		player.player_body.animationTree.set("parameters/Movement/transition_request", "Idle_TurnLeft")
	
	if not player.is_on_floor():
		state_machine.transition_to("Air")
		
	if Input.is_action_just_pressed("Jump"):
		if player.isPauseMenuOpened or Network.game.chatText.has_focus():
			return
		state_machine.transition_to("Air", {"jump" = true})

	if (player.direction.x != 0 or player.direction.z != 0) and player.is_on_floor():
		state_machine.transition_to("Walk")
	
	if Input.is_action_pressed("Crouch"):
		state_machine.transition_to("Crouch")

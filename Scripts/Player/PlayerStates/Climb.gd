extends PlayerState

# Called when the node enters the scene tree for the first time.
func enter(_msg := {}):
	player.hud.visible = false
	player.arms.visible = false
	player.arms.process_mode = Node.PROCESS_MODE_DISABLED
	player.player_body.visible = false
	
	player.thirdPersonCam.current = true
	player.camera.current = false

func _physics_update(delta):
	pass

func update(_delta: float):
	pass

func exit():
	player.hud.visible = true
	player.arms.visible = true
	player.arms.process_mode = Node.PROCESS_MODE_INHERIT
	player.player_body.visible = true
	
	if not player.thirdPersonEnabled:
		player.thirdPersonCam.current = false
		player.camera.current = true
	else:
		player.thirdPersonCam.current = true
		player.camera.current = false

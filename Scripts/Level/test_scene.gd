extends Node3D

@onready var player : Player = $FadeShader/SubViewport/DitheringShader/SubViewport/Character

# Called when the node enters the scene tree for the first time.
func _ready():
	player.hud.visible = false
	player.arms.weaponHolder.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	if Input.is_action_just_pressed("Fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_enter_firing_range_area_body_entered(body):
	if not player.arms.weaponHolder.visible:
		player.arms.animationPlayer.play("SwapWeapon")
		await get_tree().create_timer(0.2).timeout
		player.hud.visible = true
		player.arms.weaponHolder.visible = true


func _on_exit_firing_range_area_body_entered(body):
	player.arms.animationPlayer.play("SwapWeapon")
	await get_tree().create_timer(0.2).timeout
	player.hud.visible = false
	player.arms.weaponHolder.visible = false

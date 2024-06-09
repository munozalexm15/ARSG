extends Node3D

@onready var player : Player = $FadeShader/SubViewport/DitheringShader/SubViewport/Character


@export var pauseNode := NodePath()
@onready var pauseMenu : Pause_Menu = get_node(pauseNode)

var startCountdown : bool = false
var timeLeft : Timer = Timer.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	player.hud.visible = false
	player.arms.weaponHolder.hide()
	timeLeft.autostart = false
	timeLeft.wait_time = 60
	add_child(timeLeft)
	pauseMenu.visible = false
 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if startCountdown:
		timeLeft.start()
		timeLeft.wait_time = 60
		startCountdown = false
		if not timeLeft.timeout.is_connected(on_timerLeft_end):
			timeLeft.timeout.connect(on_timerLeft_end)
	
	player.hud.timeLabel.text = str(int(timeLeft.time_left))

func _input(event):
	if Input.is_action_just_pressed("Fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

	if Input.is_action_just_pressed("Pause") and not get_tree().paused:
		pauseMenu.show()
		pauseMenu.animationPlayer.play("OpenMenu")
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
		get_tree().paused = not get_tree().paused
		
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


func _on_character_challenge():
	startCountdown = true

func on_timerLeft_end():
	player.hud.timerContainer.visible = false

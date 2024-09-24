extends Node3D

@onready var player : Player = $FadeShader/SubViewport/DitheringShader/SubViewport/Character

var startCountdown : bool = false
var timeLeft : Timer = Timer.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	timeLeft.autostart = false
	timeLeft.wait_time = 60
	add_child(timeLeft)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if startCountdown:
		timeLeft.start()
		timeLeft.wait_time = 60
		startCountdown = false
		if not timeLeft.timeout.is_connected(on_timerLeft_end):
			timeLeft.timeout.connect(on_timerLeft_end)
	
	player.hud.timeLabel.text = str(int(timeLeft.time_left))

func _input(_event):
	if Input.is_action_just_pressed("Fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func on_timerLeft_end():
	player.hud.timerContainer.visible = false

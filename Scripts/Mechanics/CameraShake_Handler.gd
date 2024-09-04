extends Camera3D

@export var randomStrength : float = 30.0
@export var shakeFade: float = 5.0

var shakeStrength : float = 0.0

var mouse : Vector2 = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func apply_camera_shake():
	shakeStrength = randomStrength

func randomizeCamOffset() -> Vector2:
	return Vector2(randf_range(-shakeStrength, shakeStrength), randf_range(-shakeStrength, shakeStrength))

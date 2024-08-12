class_name MainMenuNode
extends Node3D

@export var lightArray : Array

@export var cameraNode : NodePath
@onready var camera : Camera3D = get_node(cameraNode)

@onready var mortarSound : AudioStreamPlayer = $ASP_MortarSound
@onready var lightBuzzSound : AudioStreamPlayer = $ASP_LightBuzzSound
@onready var animationPlayer : AnimationPlayer = $AnimationPlayer

@onready var menu_ui : Control = $menu_ui

#PSX Cones Array
var meshesArray : Array
var spotLightArray : Array

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	animationPlayer.play("Fade_in")
	for mesh in lightArray:
		var node = get_node(mesh)
		var children = node.get_children()
		
		for child in children:
			if child is Node3D:
				meshesArray.append(child)
			if child is SpotLight3D:
				spotLightArray.append(child)
	
	lightError()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if camera.shakeStrength >0:
		camera.shakeStrength = lerpf(camera.shakeStrength, 0, camera.shakeFade * delta)
		
		var shakeOffset : Vector2 = camera.randomizeCamOffset()
		camera.h_offset = shakeOffset.x
		camera.v_offset = shakeOffset.y

func lightError():
	var randomTime = randi_range(5, 10)
	await get_tree().create_timer(randomTime).timeout
	camera.randomStrength = randf_range(0.05, 0.2)
	camera.apply_camera_shake()
	mortarSound.play()
	
	for i in range(3):
		var randomLightOutTime = randf_range(0, 0.5)
		var random_index = randi_range(0, spotLightArray.size() -1)
		var mesh : Node = meshesArray[random_index]
		var light : Node = spotLightArray[random_index]
		mesh.visible = false
		light.visible = false
		await  get_tree().create_timer(randomLightOutTime).timeout
		mesh.visible = true
		light.visible = true
	
	lightError()
	lightBuzzSound.play()

extends Node3D

@export var lightArray : Array

@export var cameraNode : NodePath
@onready var camera : Camera3D = get_node(cameraNode)

#PSX Cones Array
var meshesArray : Array
var spotLightArray : Array

# Called when the node enters the scene tree for the first time.
func _ready():
	for mesh in lightArray:
		var node = get_node(mesh)
		var children = node.get_children()
		
		for child in children:
			print(child.get_class())
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
	camera.apply_camera_shake()
	
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
	


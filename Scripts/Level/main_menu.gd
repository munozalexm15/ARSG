extends Node3D

@export var lightArray : Array

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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

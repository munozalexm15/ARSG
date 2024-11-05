extends Node

@export var pad_resource : pickupPadResource
@onready var animPlayer : AnimationPlayer = $AnimationPlayer

@onready var pickupMesh : MeshInstance3D = $grenade/MeshDisplay
@onready var bubbleMesh : MeshInstance3D = $grenade/Bubble

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animPlayer.play("Idle")
	bubbleMesh.set_surface_override_material(0, bubbleMesh.get_active_material(0).duplicate())
	pickupMesh.mesh = pad_resource.displayMesh
	pickupMesh.rotation = pad_resource.meshRotation
	pickupMesh.scale = pad_resource.meshScale
	pickupMesh.position = pad_resource.meshPosition
	
	bubbleMesh.get_active_material(0).albedo_color = pad_resource.bubbleColor
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

class_name BulletDecalPool extends Node

static func spawn_bullet_decal(global_pos : Vector3, normal : Vector3, parent : Node3D, bullet_basis : Basis, texture_override = null):
	var decal_instance : Node3D
	decal_instance = preload("res://Scenes/Mechanics/bullet_decal.tscn").instantiate()
	parent.add_child(decal_instance)
	
	# Rotate decal towards player for things like horizontal knife slash decals
	decal_instance.global_transform = Transform3D(bullet_basis, global_pos) * Transform3D(Basis().rotated(Vector3(1,0,0), deg_to_rad(90)), Vector3())
	# Align to surface
	decal_instance.global_basis = Basis(Quaternion(decal_instance.global_basis.y, normal)) * decal_instance.global_basis
	
	#decal_instance.get_node("GPUParticles3D").emitting = true
	
	if texture_override is Texture2D:
		decal_instance.texture_albedo = texture_override
	return decal_instance

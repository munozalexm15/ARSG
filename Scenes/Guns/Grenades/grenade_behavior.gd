class_name Grenade
extends Node3D

@onready var arms : Arms = $".."

@onready var grenadeParent : Node3D = $Player_Arms/GrenadeParent

@onready var animPlayer : AnimationPlayer = $Player_Arms/AnimationPlayer

@onready var leftHand : MeshInstance3D = $Player_Arms/Armature_001/Skeleton3D/Cube_002
@onready var rightHand : MeshInstance3D = $Player_Arms/Armature_001/Skeleton3D/Cube_001

var grenadeScene : PackedScene = preload("res://Scenes/Guns/Grenades/Grenade.tscn")
var grenadeThrown : GrenadeThrown = null

@onready var throwSound : AudioStreamPlayer3D = $AudioStreamPlayer3D

@onready var sphereMesh : MeshInstance3D = $Player_Arms/GrenadeParent/Sphere

func _ready() -> void:
	pass

#When is just about to throw the grenade, we change its parent and add it to the map itself
func _on_sphere_visibility_changed() -> void:
	#instanciar en la posicion de la esfera la granada
	if sphereMesh.visible:
		return
	if not sphereMesh.visible and arms.readyToThrow:
		throw_grenade.rpc(arms.player.name)

@rpc("any_peer", "call_local", "reliable")
func throw_grenade(pID):
	print("lanzo nade")
	var p : Player = Network.findPlayer(pID)
	p.player_body.RightHandB_Attachment.get_child(0).visible = false
	p.arms.grenade.grenadeThrown.mass = 1
	p.arms.grenade.grenadeThrown.instigator_id = p.name.to_int()
	p.arms.grenade.remove_child(grenadeThrown)
	Network.game.add_child(grenadeThrown)
	p.arms.grenade.grenadeThrown.global_position = grenadeParent.global_position
	#forward
	p.arms.grenade.grenadeThrown.apply_central_impulse(-p.global_transform.basis.z * 20)
	#camera y rotation impulseg
	p.arms.grenade.grenadeThrown.apply_impulse(p.global_transform.basis.y * arms.player.eyes.rotation.x * 30)
	await get_tree().create_timer(0.1).timeout
	p.arms.grenade.grenadeThrown.visible = true

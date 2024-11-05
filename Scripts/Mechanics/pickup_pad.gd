extends Node3D

@export var pad_resource : pickupPadResource
@onready var animPlayer : AnimationPlayer = $AnimationPlayer

@onready var pickupMesh : MeshInstance3D = $grenade/MeshDisplay
@onready var bubbleMesh : MeshInstance3D = $grenade/Bubble

@onready var cooldownTimer : Timer = $CooldownTimer

@export var padResourcesArray : Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var randIndex : int = randi_range(0, padResourcesArray.size() -1)
	#when someone joins, will randomize everything again. It is intended to prevent people camping weapons / buffs
	randomize_pad_resource.rpc(randIndex)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

@rpc("any_peer", "call_local", "reliable")
func randomize_pad_resource(arrayIndex : int):
	pad_resource = padResourcesArray[arrayIndex]
	bubbleMesh.set_surface_override_material(0, bubbleMesh.get_active_material(0).duplicate())
	pickupMesh.mesh = pad_resource.displayMesh
	pickupMesh.rotation = pad_resource.meshRotation
	pickupMesh.scale = pad_resource.meshScale
	pickupMesh.position = pad_resource.meshPosition
	
	bubbleMesh.get_active_material(0).albedo_color = pad_resource.bubbleColor
	
	visible = true
	animPlayer.play("popUp")

func _on_area_3d_body_entered(body: Node3D) -> void:
	if not body.is_class("CharacterBody3D") or !visible:
		return
		
	if pad_resource.resourceType == "Ammo":
		for weapon : Weapon in body.arms.weaponHolder.get_children():
			if weapon.weaponData.reserveAmmo >= weapon.weaponData.defaultReserveAmmo * 2:
				return
			
			weapon.weaponData.reserveAmmo += weapon.weaponData.magSize * pad_resource.quantity
	
	if pad_resource.resourceType == "Grenade":
		if body.arms.grenadeQuantity == 4:
			return
		
		if body.arms.grenadeQuantity >= 2:
			body.arms.grenadeQuantity = 4
		
		else:
			body.arms.grenadeQuantity += 2
		
		body.hud.grenadeCountLabel.text = str("x" , body.arms.grenadeQuantity)
	
	if pad_resource.resourceType == "Health":
		if body.health >= 100:
			return
		
		body.health += pad_resource.quantity
		if body.health > 100:
			body.health = 100
	
	visible = false
	cooldownTimer.start()

func _on_cooldown_timer_timeout() -> void:
	var randIndex : int = randi_range(0, padResourcesArray.size() - 1)
	randomize_pad_resource.rpc(randIndex)
	


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "popUp":
		animPlayer.play("Idle")

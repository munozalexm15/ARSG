extends Node3D

@export var pad_resource : pickupPadResource
@onready var animPlayer : AnimationPlayer = $AnimationPlayer

@onready var pickupMesh : MeshInstance3D = $grenade/MeshDisplay
@onready var bubbleMesh : MeshInstance3D = $grenade/Bubble

@onready var cooldownTimer : Timer = $CooldownTimer

@export var padResourcesArray : Array

# 1
func _ready() -> void:
	var randIndex : int = randi_range(0, padResourcesArray.size() -1)
	#when someone joins, will randomize everything again. It is intended to prevent people camping weapons / buffs
	randomize_pad_resource.rpc(randIndex)


func _process(delta: float) -> void:
	pass

#2 / 7
@rpc("any_peer", "call_local", "reliable")
func randomize_pad_resource(arrayIndex : int):
	pad_resource = padResourcesArray[arrayIndex]
	var mat = bubbleMesh.get_active_material(0).duplicate()
	bubbleMesh.set_surface_override_material(0, mat)
	pickupMesh.mesh = pad_resource.displayMesh
	pickupMesh.rotation = pad_resource.meshRotation
	pickupMesh.scale = pad_resource.meshScale
	pickupMesh.position = pad_resource.meshPosition
	
	bubbleMesh.get_active_material(0).albedo_color = pad_resource.bubbleColor
	
	#if someone has joined the room and a player before picked up a buff, stop the timer so it doesn't desync with the others players
	if not cooldownTimer.is_stopped():
		cooldownTimer.stop()
		
	visible = true
	animPlayer.play("popUp")

#3
func _on_area_3d_body_entered(body: Node3D) -> void:
	if not body.is_class("CharacterBody3D") or !visible:
		return
	
	pickup_interacted.rpc(body.name)
	if not cooldownTimer.paused:
		await cooldownTimer.timeout
		var randIndex : int = randi_range(0, padResourcesArray.size() - 1)
		randomize_pad_resource.rpc(randIndex)

#4
@rpc("any_peer", "call_local", "reliable")
func pickup_interacted(pID):
	var used = pickup_behavior_locally(pID)
	if not used:
		return
		
	cooldown.rpc()

#5
@rpc("any_peer", "call_local", "reliable")
func cooldown():
	visible = false
	cooldownTimer.start(10)

func pickup_behavior_locally(pID) -> bool:
	var body : Player = Network.findPlayer(pID)
	
	if body == null:
		return false
	#This is done to replicate in every computer
	if pad_resource.resourceType == "Health":
		return handle_health(body)
	
	#this part only is handled in client. I know this is an exploit for cheaters atm.
	if pad_resource.resourceType == "Ammo":
		return handle_ammo(body)
	
	if pad_resource.resourceType == "Grenade":
		return handle_grenades(body)
	
	return false


func handle_health(body):
	if body.health >= 100:
		print("no cumple requisito salud")
		return false
		
		
	body.health += pad_resource.quantity
	if body.health > 100:
		body.health = 100
	
	return true

func handle_ammo(body):
	if body.arms.actualWeapon.weaponData.reserveAmmo >= body.arms.actualWeapon.weaponData.defaultReserveAmmo * 2:
		print("no cumple requisito municion")
		return false
	
	body.arms.actualWeapon.weaponData.reserveAmmo += body.arms.actualWeapon.weaponData.defaultReserveAmmo
	print("cumple requisito balas")
	return true
	
func handle_grenades(body):
	print(body.arms.grenadeQuantity)
	if body.arms.grenadeQuantity == 4:
		print("no cumple requisito granadas")
		return false
	
	if body.arms.grenadeQuantity >= 2:
		body.arms.grenadeQuantity = 4
	else:
		body.arms.grenadeQuantity += 2
	
	body.hud.grenadeCountLabel.text = str("x" , body.arms.grenadeQuantity)
	
	return true

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "popUp":
		animPlayer.play("Idle")

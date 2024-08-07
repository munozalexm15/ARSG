class_name ChestInteractable
extends Node3D


@export var WeaponList: Array
@onready var spawnPoint : Node3D = $SpawnPoint

@onready var animationPlayer : AnimationPlayer = $AnimationPlayer
var opened = false
var selectedWeapon : String

@onready var lid_collision : CollisionShape3D = $chest_model/Chest_1/Chest_1_lid/StaticBody3D/CollisionShape3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

@rpc("any_peer", "call_local", "reliable")
func spawn_weapon(weaponPath : String):
	opened = true
	lid_collision.disabled = false
	var weaponScene = load(weaponPath)
	var weapon_to_spawn : WeaponInteractable = weaponScene.instantiate()
	
	Network.game.interactables_node.add_child(weapon_to_spawn)
	weapon_to_spawn.global_position = spawnPoint.global_position
	animationPlayer.play("Open_Chest", -1, 1, false)

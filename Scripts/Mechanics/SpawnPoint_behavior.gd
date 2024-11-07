class_name SpawnPoint
extends Node3D

@onready var visibleOnScreen : VisibleOnScreenNotifier3D
var canPlayerSpawn : bool = true

var playersInArea3D: Array = []

#CASUISTICAS SPAWNS:
#-1: Get player global position and spawn global position distance (with abs). Get the greater spawn distance and make it spawn there if:
 #-1: Is not visible by the player
 #-2: Is not inside the area3D 

func _on_visible_on_screen_notifier_3d_screen_entered() -> void:
	isNotSafeToSpawn.rpc()


func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
	isSafeToSpawn.rpc()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_class("CharacterBody3D"):
		playerEntered.rpc(body.name)

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_class("CharacterBody3D"):
		playerExited.rpc(body.name)



@rpc("any_peer", "call_local")
func isNotSafeToSpawn():
	canPlayerSpawn = false

@rpc("any_peer", "call_local")
func isSafeToSpawn():
	canPlayerSpawn = true

@rpc("any_peer", "call_local")
func playerEntered(pID):
	var p : Player = Network.findPlayer(pID)
	playersInArea3D.append(p)

@rpc("any_peer", "call_local")
func playerExited(pID):
	var p : Player = Network.findPlayer(pID)
	playersInArea3D.erase(p)

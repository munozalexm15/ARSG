class_name FloatingHead

extends Node3D

var player_ref : Player = null

@export var noisesArray : Array

signal showText(text)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimationPlayer.play("Float")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player_ref != null:
		look_at(player_ref.position)
		rotation.x = 0
		rotation.z = 0

func _on_area_3d_2_body_entered(body: Node3D) -> void:
	player_ref = body
	player_ref.hud.crosshair.visible = false
	player_ref.hud.weaponStatsContainer.visible = false

func _on_area_3d_2_body_exited(body: Node3D) -> void:
	player_ref.hud.crosshair.visible = true
	player_ref.hud.weaponStatsContainer.visible = true
	player_ref = null

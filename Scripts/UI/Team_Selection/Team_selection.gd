class_name WeaponSelection_Menu
extends Control

var player : Player

# Called when the node enters the scene tree for the first time.
func _ready():
	if not is_multiplayer_authority(): 
		visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED

func _on_mp_5_button_pressed():
	Network.updatePlayerWeapon.rpc(player.name, "res://Scenes/Guns/MP5.tscn")


func _on_m_16_button_pressed():
	Network.updatePlayerWeapon.rpc(player.name, "res://Scenes/Guns/M16A2.tscn")


func _on_sniper_button_pressed():
	Network.updatePlayerWeapon.rpc(player.name, "res://Scenes/Guns/remington_700.tscn")


func _on_shotgun_button_pressed():
	Network.updatePlayerWeapon.rpc(player.name, "res://Scenes/Guns/remington_870.tscn")

func show_player():
	player.visible = true
	visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN 

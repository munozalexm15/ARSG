class_name WeaponSelection_Menu
extends Control

var player : Player

@onready var m16Preview : WeaponSelectionInformation = $SubViewportContainer/SubViewport/Node3D/M16
@onready var r870Preview : WeaponSelectionInformation = $SubViewportContainer/SubViewport/Node3D/r870
@onready var r700Preview : WeaponSelectionInformation = $SubViewportContainer/SubViewport/Node3D/r700
@onready var mp5Preview : WeaponSelectionInformation = $SubViewportContainer/SubViewport/Node3D/mp5
@onready var m14Preview : WeaponSelectionInformation = $SubViewportContainer/SubViewport/Node3D/m14

@onready var weaponNameLabel :Label = $WeaponName
@onready var weaponDescLabel : Label = $WeaponDescription

@onready var animPlayer : AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	if not is_multiplayer_authority(): 
		visible = false
	animPlayer.play("weapon_preview")


func _input(event: InputEvent) -> void:
	if player.arms.weaponHolder.get_child_count() <= 0:
		return
	
	if Input.is_action_just_pressed("Pause") and visible:
		visible = false
		player.hud.animationPlayer.play("swap_gun", -1, 100.0, false)
		player.isPauseMenuOpened = false

func _on_mp_5_button_pressed():
	Network.updatePlayerWeapon.rpc(player.name, "res://Scenes/Guns/MP5.tscn")

func _on_mp_5_button_focus_entered() -> void:
	m16Preview.visible = false
	r870Preview.visible = false
	r700Preview.visible = false
	m14Preview.visible = false
	mp5Preview.visible = true
	weaponNameLabel.visible = true
	weaponDescLabel.visible = true
	weaponNameLabel.text = mp5Preview.weaponInfoResource.name
	weaponDescLabel.text = mp5Preview.weaponInfoResource.description
	
func _on_m_16_button_focus_entered() -> void:
	m16Preview.visible = true
	r870Preview.visible = false
	r700Preview.visible = false
	m14Preview.visible = false
	mp5Preview.visible = false
	weaponNameLabel.visible = true
	weaponDescLabel.visible = true
	weaponNameLabel.text = m16Preview.weaponInfoResource.name
	weaponDescLabel.text = m16Preview.weaponInfoResource.description


func _on_sniper_button_focus_entered() -> void:
	m16Preview.visible = false
	r870Preview.visible = false
	r700Preview.visible = true
	m14Preview.visible = false
	mp5Preview.visible = false
	weaponNameLabel.visible = true
	weaponDescLabel.visible = true
	weaponNameLabel.text = r700Preview.weaponInfoResource.name
	weaponDescLabel.text = r700Preview.weaponInfoResource.description


func _on_shotgun_button_focus_entered() -> void:
	m16Preview.visible = false
	r870Preview.visible = true
	r700Preview.visible = false
	m14Preview.visible = false
	mp5Preview.visible = false
	weaponNameLabel.visible = true
	weaponDescLabel.visible = true
	weaponNameLabel.text = r870Preview.weaponInfoResource.name
	weaponDescLabel.text = r870Preview.weaponInfoResource.description


func _on_m_14_button_focus_entered() -> void:
	m16Preview.visible = false
	r870Preview.visible = false
	r700Preview.visible = false
	m14Preview.visible = true
	mp5Preview.visible = false
	weaponNameLabel.visible = true
	weaponDescLabel.visible = true
	weaponNameLabel.text = m14Preview.weaponInfoResource.name
	weaponDescLabel.text = m14Preview.weaponInfoResource.description

func _on_m_16_button_pressed():
	Network.updatePlayerWeapon.rpc(player.name, "res://Scenes/Guns/M16A2.tscn")


func _on_sniper_button_pressed():
	Network.updatePlayerWeapon.rpc(player.name, "res://Scenes/Guns/remington_700.tscn")


func _on_shotgun_button_pressed():
	Network.updatePlayerWeapon.rpc(player.name, "res://Scenes/Guns/remington_870.tscn")


func _on_m_14_button_pressed() -> void:
	Network.updatePlayerWeapon.rpc(player.name, "res://Scenes/Guns/M14.tscn")


func hide_all():
	m16Preview.visible = false
	r870Preview.visible = false
	r700Preview.visible = false
	m14Preview.visible = false
	mp5Preview.visible = false
	weaponNameLabel.visible = false
	weaponDescLabel.visible = false

func show_player():
	player.visible = true
	visible = false


func _on_visibility_changed():
	if not is_multiplayer_authority():
		return
	
	if visible:
		player.hud.visible = false
		Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	else:
		player.hud.visible = true
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED 
		player.isPauseMenuOpened = false
		player.state_machine.process_mode = PROCESS_MODE_INHERIT

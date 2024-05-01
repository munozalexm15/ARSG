class_name HUD
extends Control

@export var dot_radius : float = 1.0
@export var dot_color : Color = Color.WHITE

@export var reticle_speed : float = 0.25
@export var retoile_distance : float = 2.0
@export var reticle_lines : Array[Line2D]
@export var player_controller : CharacterBody3D

@onready var ammoCounter = $PanelContainer/HBoxContainer/VBoxContainer2/AmmoIndicator
@onready var weaponFireMode = $PanelContainer/HBoxContainer/VBoxContainer/FireMode
@onready var weaponCaliber = $PanelContainer/HBoxContainer/VBoxContainer/WeaponCaliber
@onready var crosshair = $CenterContainer

@onready var primaryWeaponIcon : TextureRect = $VBoxContainer/PrimaryWeaponImage
@onready var secondaryWeaponIcon : TextureRect= $VBoxContainer/SecondaryWeaponImage

@onready var pickupAmmoContainer : VBoxContainer = $CenterContainer2/HBoxContainer/PickupAmmoContainer2
@onready var marginContainer : MarginContainer = $CenterContainer2/HBoxContainer/MarginContainer
@onready var pickupWeaponContainer : VBoxContainer = $CenterContainer2/HBoxContainer/PickupWeaponContainer

@onready var animationPlayer : AnimationPlayer = $AnimationPlayer

@onready var fpsCounter : Label = $FPSCOUNTER

# Called when the node enters the scene tree for the first time.
func _ready():
	crosshair.queue_redraw()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	fpsCounter.set_text("FPS %d" % Engine.get_frames_per_second())
	if Input.is_action_pressed("ADS"):
		crosshair.queue_redraw()
		for x in reticle_lines.size():
			reticle_lines[x].visible = false
	else:
		crosshair.queue_redraw()
		for x in reticle_lines.size():
			reticle_lines[x].visible = true
		adjust_reticle_size()
	

func adjust_reticle_size():
	var player_velocity = player_controller.get_real_velocity()
	var origin = Vector3(0,0,0)
	var pos =Vector2(0,0)
	var speed = origin.distance_to(player_velocity)
	
	
	#top and bottom
	reticle_lines[0].position = lerp(reticle_lines[0].position, pos + Vector2(0, -speed * retoile_distance), reticle_speed)
	reticle_lines[2].position = lerp(reticle_lines[2].position, pos + Vector2(0, speed * retoile_distance), reticle_speed)
	#left and right
	reticle_lines[1].position = lerp(reticle_lines[1].position, pos + Vector2(speed * retoile_distance, 0), reticle_speed)
	reticle_lines[3].position = lerp(reticle_lines[3].position, pos + Vector2(-speed * retoile_distance, 0), reticle_speed)

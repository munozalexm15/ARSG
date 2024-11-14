class_name HUD
extends Control

@export var dot_radius : float = 1.0
@export var dot_color : Color = Color.WHITE

@export var reticle_speed : float = 0.25
@export var retoile_distance : float = 2.0
@export var reticle_lines : Array[Line2D]
@export var player_controller : Player


@onready var weaponStatsContainer = $PanelContainer

@onready var ammoCounter = $PanelContainer/HBoxContainer/VBoxContainer2/AmmoIndicator
@onready var weaponFireMode = $PanelContainer/HBoxContainer/VBoxContainer/FireMode
@onready var weaponCaliber = $PanelContainer/HBoxContainer/VBoxContainer/WeaponCaliber
@onready var crosshair = $CenterContainer

@onready var primaryWeaponIcon : TextureRect = $VBoxContainer/PrimaryWeaponImage
@onready var secondaryWeaponIcon : TextureRect= $VBoxContainer/SecondaryWeaponImage

@onready var grenadeCountLabel : Label = $PanelContainer/HBoxContainer/VBoxContainer2/HBoxContainer/GrenadeCount

@onready var pickupAmmoContainer : VBoxContainer = $CenterContainer2/HBoxContainer/PickupAmmoContainer2
@onready var marginContainer : MarginContainer = $CenterContainer2/HBoxContainer/MarginContainer
@onready var pickupWeaponContainer : VBoxContainer = $CenterContainer2/HBoxContainer/PickupWeaponContainer

@onready var sniperSight : TextureRect = $PrecisionSightContainer/TextureRect

@onready var animationPlayer : AnimationPlayer = $AnimationPlayer
@onready var aimAnimationPlayer : AnimationPlayer = $PrecisionSightContainer/AnimationPlayerSniper

@onready var healthBar : ProgressBar = $PanelContainer2/VBoxContainer/ProgressBar

@onready var interactContainer :VBoxContainer = $CenterContainer2/HBoxContainer/InteractContainer

@onready var InfoAnimationPlayer: AnimationPlayer = $InformationContainer/InformationAnimPlayer
@onready var NPCNameLabel : Label = $InformationContainer/VBoxContainer/Name
@onready var NPCRoleLabel : Label = $InformationContainer/VBoxContainer/Role

@onready var HurtScreenContainer : PanelContainer = $HurtScreenContainer
@onready var HurtScreenAnimationPlayer : AnimationPlayer = $HurtScreenContainer/AnimationPlayer

@onready var killPointsAnimPlayer : AnimationPlayer = $KillPointsHUDContainer/AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	if not is_multiplayer_authority():
		visible = false
		return
	
	crosshair.queue_redraw()
	
	NPCNameLabel.visible = false
	NPCRoleLabel.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if not is_multiplayer_authority():
		return
		
	if Input.is_action_pressed("ADS") or player_controller.arms.state_machine.state.name == "Reload":
		crosshair.queue_redraw()
		for x in reticle_lines.size():
			reticle_lines[x].visible = false
	else:
		crosshair.queue_redraw()
		for x in reticle_lines.size():
			reticle_lines[x].visible = true
		adjust_reticle_size()
	
	healthBar.value = player_controller.health
	
func adjust_reticle_size():
	if not is_multiplayer_authority():
		return
		
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

func ally_indicator(sight_color : Color):
	if not is_multiplayer_authority():
		return

	if reticle_lines[0].default_color == sight_color:
		return

	reticle_lines[0].default_color = sight_color
	reticle_lines[2].default_color = sight_color
	#left and right
	reticle_lines[1].default_color = sight_color
	reticle_lines[3].default_color = sight_color
	

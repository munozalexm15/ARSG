extends Node3D

@export var WEAPON_TYPE : Weapons

@onready var weapon_body = $Body
@onready var weapon_slide = $Slide
@onready var weapon_trigger_hammer = $Trigger_Hammer
@onready var weapon_mag = $Mag

# Called when the node enters the scene tree for the first time.
func _ready():
	load_weapon()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func load_weapon():
	weapon_body = WEAPON_TYPE.body
	weapon_slide = WEAPON_TYPE.slide
	weapon_trigger_hammer = WEAPON_TYPE.trigger_hammer
	weapon_mag = WEAPON_TYPE.mag
	
	position = WEAPON_TYPE.position
	rotation_degrees = WEAPON_TYPE.rotation

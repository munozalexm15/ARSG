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
	#el problema de que no carguen creo que es que es un Mesh en el resource y aqui es un meshInstance3d
	print(WEAPON_TYPE.name)
	weapon_body.mesh = WEAPON_TYPE.body
	weapon_slide.mesh = WEAPON_TYPE.slide
	weapon_trigger_hammer.mesh = WEAPON_TYPE.trigger
	weapon_mag.mesh = WEAPON_TYPE.mag
	
	position = WEAPON_TYPE.position
	rotation_degrees = WEAPON_TYPE.rotation

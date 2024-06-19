extends Node3D

@onready var target : Target = $Prop_Target_Pole2/Prop_Target_Human/StaticBody3D
@export var targetData : HumanTargetData

@onready var healthBar : ProgressBar = $SubViewport/ProgressBar

# Called when the node enters the scene tree for the first time.
func _ready():
	target.targetData = targetData
	healthBar.value = targetData.actualHealth


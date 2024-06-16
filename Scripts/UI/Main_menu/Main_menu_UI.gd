extends Control

# Called when the node enters the scene tree for the first time.

var firingRange = preload("res://Scenes/Levels/test_scene.tscn").instantiate()

@onready var OptionsContainer = $SettingsMenu

func _ready():
	$AnimationPlayer.play("Fade_in")
	OptionsContainer.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_firing_range_play_pressed():
	# get_tree().root.add_child(firingRange)
	get_tree().change_scene_to_file("res://Scenes/Levels/test_scene.tscn")

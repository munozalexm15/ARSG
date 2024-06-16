extends Control

# Called when the node enters the scene tree for the first time.

var firingRange = preload("res://Scenes/Levels/test_scene.tscn").instantiate()

@onready var optionsMainContainer = $SettingsMenu

func _ready():
	$AnimationPlayer.play("Fade_in")
	optionsMainContainer.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_firing_range_play_pressed():
	# LOAD NEXT LEVEL IN ANOTHER THREAD, SHOW LOADING SCREEN
	LoadScreenHandler.next_scene = "res://Scenes/Levels/test_scene.tscn"
	get_tree().change_scene_to_packed(LoadScreenHandler.loading_screen)


func _on_options_button_pressed():
	if optionsMainContainer.visible:
		optionsMainContainer.animationPlayer.play("OpenOptions", -1, -2, true)
		await optionsMainContainer.animationPlayer.animation_finished
		optionsMainContainer.hide()
	else:
		optionsMainContainer.animationPlayer.play("OpenOptions", -1, 2, false)
		await optionsMainContainer.animationPlayer.animation_finished
		optionsMainContainer.show()
		optionsMainContainer.visualOptionsContainer.show()
		optionsMainContainer.soundOptionsContainer.hide()
		optionsMainContainer.controlsOptionContainer.hide()

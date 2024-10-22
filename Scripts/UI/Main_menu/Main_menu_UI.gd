extends Control
##ANTIGUO MAIN_MENU SCRIPT PARA EL VIEJO MENU, DEPRECATED


# Called when the node enters the scene tree for the first time.

var firingRange = preload("res://Scenes/Levels/test_scene.tscn").instantiate()
#var level = preload("res://Scenes/Levels/initial_level.tscn")

@export var button_hover_SFX : AudioStreamOggVorbis
@export var button_press_SFX : AudioStreamOggVorbis

@onready var optionsMainContainer = $SettingsMenu
@onready var lobbyBrowser = $LobbyBrowser
@onready var matchCreator = $MatchCreator
@onready var lobbyDetails = $JoinLobbyMenu

func _ready():
	$AnimationPlayer.play("Fade_in")
	optionsMainContainer.visible = false
	lobbyBrowser.visible = false
	matchCreator.visible = false
	lobbyDetails.visible = false
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_firing_range_play_pressed():
	# LOAD NEXT LEVEL IN ANOTHER THREAD, SHOW LOADING SCREEN
	LoadScreenHandler.next_scene = "res://Scenes/Levels/test_scene.tscn"
	get_tree().change_scene_to_packed(LoadScreenHandler.loading_screen)
	GlobalData.isOnlineMatch = false


func _on_options_button_pressed():
	lobbyBrowser.visible = false
	matchCreator.visible = false
	SFXHandler.play_sfx(button_press_SFX, self, "Effects")
	
	if optionsMainContainer.visible:
		optionsMainContainer.animationPlayer.play("OpenOptions", -1, -2, true)
		await optionsMainContainer.animationPlayer.animation_finished
		optionsMainContainer.hide()
	else:
		optionsMainContainer.show()
		optionsMainContainer.soundOptionsContainer.hide()
		optionsMainContainer.controlsOptionContainer.hide()
		optionsMainContainer.animationPlayer.play("OpenOptions", -1, 2, false)
		await optionsMainContainer.animationPlayer.animation_finished
		
		optionsMainContainer.visualOptionsContainer.show()
		

func _on_host_button_mouse_entered():
	SFXHandler.play_sfx(button_hover_SFX, self, "Effects")

func _on_host_button_pressed():
	matchCreator.visible = !matchCreator.visible
	optionsMainContainer.visible = false
	lobbyBrowser.visible = false
	SFXHandler.play_sfx(button_press_SFX, self, "Effects")
	

func _on_join_button_pressed():
	matchCreator.visible = false
	optionsMainContainer.visible = false
	lobbyBrowser.visible = !lobbyBrowser.visible
	if lobbyBrowser.visible:
		lobbyBrowser.open_lobby_list()
	#Network.join_server()
	#GlobalData.isOnlineMatch = true
	#LoadScreenHandler.next_scene = "res://Scenes/Levels/initial_level.tscn"
	#get_tree().change_scene_to_file("res://Scenes/Levels/initial_level.tscn")

func _on_join_button_mouse_entered():
	pass # Replace with function body.

func _on_firing_range_play_mouse_entered():
	SFXHandler.play_sfx(button_hover_SFX, self, "Effects")

func _on_options_button_mouse_entered():
	SFXHandler.play_sfx(button_hover_SFX, self, "Effects")

func _on_exit_button_pressed():
	SFXHandler.play_sfx(button_press_SFX, self, "Effects")

func _on_exit_button_mouse_entered():
	SFXHandler.play_sfx(button_hover_SFX, self, "Effects")

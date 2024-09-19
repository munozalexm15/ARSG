class_name Pause_Menu
extends Control

#warp mouse es util para setear la posicion del raton y no de esos tirones al pausar el juego

#if is playing multiplayer, not enable menu if exiting the game window
var isMultiplayer : bool = false

@onready var animationPlayer : AnimationPlayer = $AnimationPlayer

@export var button_hover_SFX : AudioStreamOggVorbis
@export var button_press_SFX : AudioStreamOggVorbis

@onready var pauseMenu : VBoxContainer = $HBoxContainer2/MarginContainer/PauseMenu

@onready var optionsMainContainer : SettingsMenu = $OptionsControl

@onready var ditheringMaterial : ShaderMaterial = GlobalData.ditheringShader

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false

func _input(_event):
	if Input.is_action_just_pressed("Pause"):
		hide_menu()
	
func hide_menu():
	if optionsMainContainer.visible:
		optionsMainContainer.animationPlayer.play("OpenOptions", -1, -2, true)
		await optionsMainContainer.animationPlayer.animation_finished
		optionsMainContainer.hide()
	animationPlayer.play("OpenMenu", -1, -2, true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_viewport().set_input_as_handled()
	await animationPlayer.animation_finished
	if get_tree().paused:
		get_tree().paused = false
		hide()

func _on_settings_button_mouse_entered():
	SFXHandler.play_sfx(button_hover_SFX, self, "Effects")
	
func _on_settings_button_pressed():
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

func _on_continue_button_pressed():
	SFXHandler.play_sfx(button_press_SFX, self, "Effects")
	hide_menu()

func _on_continue_button_mouse_entered():
	SFXHandler.play_sfx(button_hover_SFX, self, "Effects")


func _on_exit_button_pressed():
	SFXHandler.play_sfx(button_press_SFX, self, "Effects")
	Network.player_left(multiplayer.get_unique_id())
	get_tree().quit()


func _on_exit_button_mouse_entered():
	SFXHandler.play_sfx(button_hover_SFX, self, "Effects")


func _on_exit_match_button_pressed():
	if get_tree().paused:
		get_tree().paused = false
	
	#CLIENT LEAVING MATCH
	if multiplayer.get_unique_id() != 1:
		Network.player_left.rpc(multiplayer.get_unique_id())
		Network.leave_lobby()
		get_tree().change_scene_to_file("res://Scenes/Menu/main_menu.tscn")
	#HOST CLOSING MATCH
	else:
		var lobbyId = Network.lobby_id 
		for x in Steam.getNumLobbyMembers(lobbyId):
			var member_steam_id = Steam.getLobbyMemberByIndex(lobbyId, x)
			var peer_id= Network.peer.get_peer_id_from_steam64(member_steam_id)
			if peer_id == 1:
				continue
			
			Network.exit_and_return_to_main_menu.rpc_id(peer_id)
	
		Network.peer.close()
		get_tree().change_scene_to_file("res://Scenes/Menu/main_menu.tscn")

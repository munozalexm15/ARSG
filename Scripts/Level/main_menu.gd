class_name MainMenuNode
extends Node3D

@export var lightArray : Array

@export var cameraNode : NodePath
@onready var camera : Camera3D = get_node(cameraNode)
@onready var cameraAnimPlayer : AnimationPlayer = $FadeShader/SubViewport/DitheringShader/SubViewport/Camera3D/CameraAnimPlayer

@onready var mortarSound : AudioStreamPlayer = $ASP_MortarSound
@onready var lightBuzzSound : AudioStreamPlayer = $ASP_LightBuzzSound

#PSX Cones Array
var meshesArray : Array
var spotLightArray : Array

@onready var optionsUI : Control = $OptionsControl/OptionsUI
@onready var hostUI : Control = $HostingMatchControl
@onready var lobbiesListUI : Control = $LobbiesControl

@onready var playLabel : Label3D = $PlayLable
@onready var laptopScreenMesh : MeshInstance3D = $Laptop01/Laptop01_Lid/Screen
@onready var animPlayerPlayLabel : AnimationPlayer = $PlayLable/AnimationPlayer

@onready var quitLabel : Label3D = $QuitLabel
@onready var quitYesLabel : Label3D = $QuitYesLabel
@onready var quitNoLabel : Label3D = $QuitNoLabel
@onready var animPlayerQuitLabel : AnimationPlayer = $QuitLabel/AnimationPlayer

@onready var optionsLabel : Label3D = $OptionsLabel
@onready var animPlayerOptionsLabel : AnimationPlayer = $OptionsLabel/AnimationPlayer
@onready var optionsControl : Control = $OptionsControl

@onready var customizationLabel : Label3D = $ClassesLabel
@onready var animPlayerCustomizationLabel : AnimationPlayer = $ClassesLabel/AnimationPlayer

@onready var flashlightLight : SpotLight3D = $OldFlashlight012/SpotLight3D

var sections : Dictionary = {"play": "menu_to_play", "options": "menu_to_options", "exit": "menu_to_exit"}
var selectedSection = ""

var screenMaterial : Material
@export var lobbyFindTexture : Texture2D 
@export var hostMatchTexture : Texture2D 

var listingLobbies = true

@export var playHover_soundEffect : AudioStreamMP3
@export var playClick_soundEffect : AudioStreamMP3

@export var settingsHover_soundEffect : AudioStreamMP3
@export var settingsClick_soundEffect : AudioStreamMP3

@export var exitHover_soundEffect : AudioStreamMP3
@export var exitClick_soundEffect : AudioStreamMP3

func _ready():
	print(Network.peer.get_connection_status())
	print(Network.peer.get_state())
	playLabel.modulate.a = 0.05
	quitLabel.modulate.a = 0.05
	optionsLabel.modulate.a = 0.05
	screenMaterial = laptopScreenMesh.get_active_material(0)
	hostUI.visible = false
	optionsUI.visible = false
	optionsControl.visible = false
	
	if get_tree().paused:
		get_tree().paused = false
	for mesh in lightArray:
		var node = get_node(mesh)
		var children = node.get_children()
		
		for child in children:
			if child is Node3D:
				meshesArray.append(child)
			if child is SpotLight3D:
				spotLightArray.append(child)
	lightError()


func _input(_event):
	if Input.is_action_pressed("Pause") and selectedSection != "":
		hostUI.visible = false
		lobbiesListUI.visible = false
		
		if selectedSection == "options":
			optionsUI.visible = false
			optionsControl.visible = false
		
		cameraAnimPlayer.play(sections.get(selectedSection), -1, -1, true)
	
		selectedSection = ""
		await cameraAnimPlayer.animation_finished
		lobbiesListUI.visible = false
		hostUI.visible = false
		optionsUI.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if camera.shakeStrength >0:
		camera.shakeStrength = lerpf(camera.shakeStrength, 0, camera.shakeFade * delta)
		
		var shakeOffset : Vector2 = camera.randomizeCamOffset()
		if selectedSection == "play":
			return
		camera.h_offset = shakeOffset.x
		camera.v_offset = shakeOffset.y

func lightError():
	
	var randomTime = randi_range(15, 30)
	await get_tree().create_timer(randomTime).timeout
	camera.randomStrength = randf_range(0.01, 0.02)
	camera.apply_camera_shake()
	mortarSound.play()
	
	for i in range(3):
		var randomLightOutTime = randf_range(0, 0.5)
		var random_index = randi_range(0, spotLightArray.size() -1)
		var mesh : Node = meshesArray[random_index]
		var light : Node = spotLightArray[random_index]
		mesh.visible = false
		light.visible = false
		await  get_tree().create_timer(randomLightOutTime).timeout
		mesh.visible = true
		light.visible = true
	
	lightError()
	lightBuzzSound.play()


#---------------Options part---------------------------
func _on_static_body_3d_mouse_entered():
	if selectedSection != "":
		return
	animPlayerOptionsLabel.queue("options_hover")
	SFXHandler.play_sfx(settingsHover_soundEffect, self, "Effects")


func _on_static_body_3d_mouse_exited():
	if selectedSection != "":
		return
	animPlayerOptionsLabel.play("options_hover", -1, -1, true)


func _on_static_body_3d_input_event(_camera, _event, _position, _normal, _shape_idx):
	if _event is InputEventMouseButton and _event.pressed:
		if _event.button_index == MOUSE_BUTTON_LEFT and selectedSection == "":
			cameraAnimPlayer.play("menu_to_options")
			selectedSection = "options"
			SFXHandler.play_sfx(settingsClick_soundEffect, self, "Effects")
			await cameraAnimPlayer.animation_finished
			
			if selectedSection == "":
				return
				
			optionsUI.animationPlayer.play("RESET")
			optionsUI.visible = true
			optionsControl.visible = true

#---------------Exit part---------------------------
func _on_quit_cartel_mouse_exited():
	if selectedSection != "":
		return
	animPlayerQuitLabel.play("quit_hover", -1, -1, true)


func _on_quit_cartel_mouse_entered():
	if selectedSection != "":
		return
	animPlayerQuitLabel.play("quit_hover")
	SFXHandler.play_sfx(exitHover_soundEffect, self, "Effects")


func _on_quit_cartel_input_event(_camera, _event, _position, _normal, _shape_idx):
	if _event is InputEventMouseButton and _event.pressed:
		if _event.button_index == MOUSE_BUTTON_LEFT and selectedSection == "":
			SFXHandler.play_sfx(exitClick_soundEffect, self, "Effects")
			cameraAnimPlayer.play("menu_to_exit")
			selectedSection = "exit"
			

func _on_no_r_body_mouse_entered():
	if selectedSection != "exit":
		return
	animPlayerQuitLabel.play("quit_no_hover")


func _on_no_r_body_mouse_exited():
	if selectedSection != "exit":
		return
	animPlayerQuitLabel.play("quit_no_hover", -1, -1, true)

func _on_no_r_body_input_event(_camera, _event, _position, _normal, _shape_idx):
	if _event is InputEventMouseButton and _event.pressed:
		if _event.button_index == MOUSE_BUTTON_LEFT:
			cameraAnimPlayer.play(sections.get(selectedSection), -1, -1, true)
			await cameraAnimPlayer.animation_finished
			selectedSection = ""


func _on_yes_r_body_mouse_entered():
	if selectedSection != "exit":
		return
	animPlayerQuitLabel.play("quit_yes_hover")

func _on_yes_r_body_mouse_exited():
	if selectedSection != "exit":
		return
	animPlayerQuitLabel.play("quit_yes_hover", -1, -1, true)

func _on_yes_r_body_input_event(_camera, _event, _position, _normal, _shape_idx):
	if _event is InputEventMouseButton and _event.pressed:
		if _event.button_index == MOUSE_BUTTON_LEFT:
			get_tree().quit()

#---------------PlayMatch part ---------------------------

func _on_keyboard_laptop_input_event(_camera, _event, _position, _normal, _shape_idx):
	if _event is InputEventMouseButton and _event.pressed:
		if _event.button_index == MOUSE_BUTTON_LEFT and selectedSection == "":
			cameraAnimPlayer.play("menu_to_play")
			selectedSection = "play"
			SFXHandler.play_sfx(playClick_soundEffect, self, "Effects")
			await cameraAnimPlayer.animation_finished
			
			if selectedSection == "":
				return
				
			if listingLobbies:
				lobbiesListUI.open_lobby_list()
			else:
				hostUI.visible = true

func _on_keyboard_laptop_mouse_entered():
	if selectedSection != "":
		return
	animPlayerPlayLabel.play("play_hover")
	SFXHandler.play_sfx(playHover_soundEffect, self, "Effects")


func _on_keyboard_laptop_mouse_exited():
	if selectedSection != "":
		return
	animPlayerPlayLabel.play("play_hover", -1, -1, true)

func _on_lobby_list_finder_r_body_input_event(_camera, _event, _position, _normal, _shape_idx):
	if _event is InputEventMouseButton and _event.pressed:
		if _event.button_index == MOUSE_BUTTON_LEFT and selectedSection == "play":
			screenMaterial.albedo_texture = lobbyFindTexture
			listingLobbies = true
			hostUI.visible = false
			lobbiesListUI.visible = true


func _on_host_match_r_body_input_event(_camera, _event, _position, _normal, _shape_idx):
	if _event is InputEventMouseButton and _event.pressed:
		if _event.button_index == MOUSE_BUTTON_LEFT and selectedSection == "play":
			screenMaterial.albedo_texture = hostMatchTexture
			listingLobbies = false
			hostUI.visible = true
			lobbiesListUI.visible = false
			for x in lobbiesListUI.lobbiesList.get_children():
				lobbiesListUI.lobbiesList.remove_child(x)
			

#---------------Customize weapons part (WIP)---------------------------
func _on_mp_5_input_event(_camera, _event, _position, _normal, _shape_idx):
	if _event is InputEventMouseButton and _event.pressed:
		if _event.button_index == MOUSE_BUTTON_LEFT and selectedSection == "":
			pass


func _on_mp_5_mouse_entered():
	#animPlayerCustomizationLabel.play("classes_hover")
	pass

func _on_mp_5_mouse_exited():
	#animPlayerCustomizationLabel.play("classes_hover", -1, -1, true)
	pass


#------------------Flashlight-------------------------------------
func _on_flashlight_input_event(_camera, _event, _position, _normal, _shape_idx):
	if _event is InputEventMouseButton and _event.pressed:
		if _event.button_index == MOUSE_BUTTON_LEFT:
			flashlightLight.visible = !flashlightLight.visible

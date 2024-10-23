extends Control

@onready var lobbyName : TextEdit = $VBoxContainer/HBoxContainer/VBoxContainer/RoomNameContainer/TextEdit
@onready var mapName : Label = $VBoxContainer/HBoxContainer/VBoxContainer/MapSelectorContainer/TextureRect/Label

var mapPathsList = [ "res://Scenes/Levels/hangar_map.tscn", "res://Scenes/Levels/Ghost_city.tscn", "res://Scenes/Levels/test_scene.tscn"]
var mapNamesList = ["Hangar", "Sunday Afternoon", "Firing Range"]
@export var mapImagesList : Array

var mapListIndex = 0

var selectedMap = ""

@onready var gamemodeOption : OptionButton = $VBoxContainer/HBoxContainer/VBoxContainer2/OptionButton
@onready var privacityOption : OptionButton = $VBoxContainer/HBoxContainer/VBoxContainer2/OptionButton2
@onready var mapImage : TextureRect = $VBoxContainer/HBoxContainer/VBoxContainer/MapSelectorContainer/TextureRect


@onready var matchTimeOption : OptionButton = $VBoxContainer/HBoxContainer/VBoxContainer2/OptionButton5
@onready var objectiveGoalOption : OptionButton = $VBoxContainer/HBoxContainer/VBoxContainer2/OptionButton4

@onready var perspectiveSelector : OptionButton = $VBoxContainer/HBoxContainer/VBoxContainer2/PerspectiveSelector


# Called when the node enters the scene tree for the first time.
func _ready():
	selectedMap = mapPathsList[mapListIndex]
	mapName.text = mapNamesList[mapListIndex]
	mapImage.texture = mapImagesList[mapListIndex]
	
func _input(event: InputEvent) -> void:
	if lobbyName.has_focus():
		if event is InputEventKey and event.is_pressed():
			if event.key_label == KEY_ENTER:
				get_viewport().set_input_as_handled()

func _on_create_room_button_pressed():
	var matchTime = matchTimeOption.text.split(" ")[0].to_int() * 60
	var objectiveGoal = objectiveGoalOption.text.split(" ")[0].to_int()
	
	if lobbyName.text == "" or lobbyName.text.replace(" ", "").length() == 0:
		lobbyName.text = gamemodeOption.text + " in " + mapName.text
	
	var roomDict = {"lobbyName" : lobbyName.text, 
	"mapName": mapName.text, 
	"mapPath" : selectedMap, 
	"mapImage" : mapImage.texture.resource_path,
	"playerQuantity" : 2,
	"gameMode" : gamemodeOption.text, 
	"time" : matchTime, 
	"goal": objectiveGoal,
	"perspective": perspectiveSelector.text,
	"obviousNotSpacewarButGameName": "ARSG",
	"version" : "0.1.2"}
	
	if privacityOption.text == "PUBLIC":
		roomDict["lobbyType"] = SteamMultiplayerPeer.LOBBY_TYPE_PUBLIC
	if privacityOption.text == "ONLY FRIENDS":
		roomDict["lobbyType"] = SteamMultiplayerPeer.LOBBY_TYPE_FRIENDS_ONLY
	if privacityOption.text == "PRIVATE":
		roomDict["lobbyType"] = SteamMultiplayerPeer.LOBBY_TYPE_PRIVATE
	
	if mapName.text == "Firing Range":
		roomDict["lobbyType"] = SteamMultiplayerPeer.LOBBY_TYPE_PRIVATE
	
	Network.host_server(roomDict)
	GlobalData.isOnlineMatch = true


func _on_previous_map_button_pressed():
	mapListIndex -= 1
	
	if mapListIndex < 0:
		mapListIndex = mapPathsList.size() -1
	
	selectedMap = mapPathsList[mapListIndex]
	mapName.text = mapNamesList[mapListIndex]
	mapImage.texture = mapImagesList[mapListIndex]
	
	if mapName.text == "Firing Range":
		privacityOption.text = "PRIVATE"
		privacityOption.disabled = true
		matchTimeOption.text = "10 MINUTES"
	else:
		privacityOption.text = "PUBLIC"
		privacityOption.disabled = false
		matchTimeOption.disabled = false

func _on_next_map_button_pressed():
	mapListIndex += 1
	
	if mapListIndex >= mapPathsList.size():
		mapListIndex = 0
	
	selectedMap = mapPathsList[mapListIndex]
	mapName.text = mapNamesList[mapListIndex]
	mapImage.texture = mapImagesList[mapListIndex]
	
	if mapName.text == "Firing Range":
		privacityOption.text = "PRIVATE"
		privacityOption.disabled = true
		matchTimeOption.text = "10 MINUTES"
		matchTimeOption.disabled = true
	else:
		privacityOption.text = "PUBLIC"
		privacityOption.disabled = false
		matchTimeOption.disabled = false

extends Control

@onready var lobbyName : TextEdit = $VBoxContainer/HBoxContainer/VBoxContainer/RoomNameContainer/TextEdit
@onready var mapName : Label = $VBoxContainer/HBoxContainer/VBoxContainer/MapSelectorContainer/TextureRect/Label

var mapPathsList = [ "res://Scenes/Levels/hangar_map.tscn", "res://Scenes/Levels/initial_level_copy.tscn"]
var mapNamesList = ["Hangar", "Flying Rectangles"]
@export var mapImagesList : Array

var mapListIndex = 0


var selectedMap = ""

@onready var playerQuantityOption : OptionButton = $VBoxContainer/HBoxContainer/VBoxContainer2/OptionButton3
@onready var gamemodeOption : OptionButton = $VBoxContainer/HBoxContainer/VBoxContainer2/OptionButton
@onready var privacityOption : OptionButton = $VBoxContainer/HBoxContainer/VBoxContainer2/OptionButton2
@onready var mapImage : TextureRect = $VBoxContainer/HBoxContainer/VBoxContainer/MapSelectorContainer/TextureRect


@onready var matchTimeOption : OptionButton = $VBoxContainer/HBoxContainer/VBoxContainer2/OptionButton5
@onready var objectiveGoalOption : OptionButton = $VBoxContainer/HBoxContainer/VBoxContainer2/OptionButton4


# Called when the node enters the scene tree for the first time.
func _ready():
	selectedMap = mapPathsList[mapListIndex]
	mapName.text = mapNamesList[mapListIndex]
	mapImage.texture = mapImagesList[mapListIndex]

func _on_create_room_button_pressed():
	var matchTime = matchTimeOption.text.split(" ")[0].to_int() * 60
	var objectiveGoal = objectiveGoalOption.text.split(" ")[0].to_int()
	
	var roomDict = {"lobbyName" : lobbyName.text, 
	"mapName": mapName.text, 
	"mapPath" : selectedMap, 
	"playerQuantity" : playerQuantityOption.text.to_int(), 
	"gameMode" : gamemodeOption.text, 
	"time" : matchTime, 
	"goal": objectiveGoal}
	
	if privacityOption.text == "PUBLIC":
		roomDict["lobbyType"] = SteamMultiplayerPeer.LOBBY_TYPE_PUBLIC
	if privacityOption.text == "FRIENDS":
		roomDict["lobbyType"] = SteamMultiplayerPeer.LOBBY_TYPE_FRIENDS_ONLY
	if privacityOption.text == "PRIVATE":
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

func _on_next_map_button_pressed():
	mapListIndex += 1
	
	if mapListIndex >= mapPathsList.size():
		mapListIndex = 0
	
	selectedMap = mapPathsList[mapListIndex]
	mapName.text = mapNamesList[mapListIndex]
	mapImage.texture = mapImagesList[mapListIndex]

extends ScrollContainer

@onready var lobbyName : TextEdit = $VBoxContainer/TextEdit

@onready var mapName : Label = $VBoxContainer/MapSelectorContainer/TextureRect/Label

var mapPathsList = [ "res://Scenes/Levels/initial_level.tscn", "res://Scenes/Levels/initial_level_copy.tscn"]
var mapNamesList = ["Flatworld", "Flying Rectangles"]

var mapListIndex = 0


var selectedMap = ""

@onready var playerQuantityOption : OptionButton = $VBoxContainer/OptionButton3
@onready var gamemodeOption : OptionButton = $VBoxContainer/OptionButton
@onready var privacityOption : OptionButton = $VBoxContainer/OptionButton2

@onready var matchTimeOption : OptionButton = $VBoxContainer/OptionButton5
@onready var objectiveGoalOption : OptionButton = $VBoxContainer/OptionButton4


# Called when the node enters the scene tree for the first time.
func _ready():
	selectedMap = mapPathsList[mapListIndex]
	mapName.text = mapNamesList[mapListIndex]

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
	LoadScreenHandler.next_scene = selectedMap


func _on_previous_map_button_pressed():
	mapListIndex -= 1
	print(mapListIndex)
	
	if mapListIndex < 0:
		mapListIndex = mapPathsList.size() -1
	
	selectedMap = mapPathsList[mapListIndex]
	mapName.text = mapNamesList[mapListIndex]
	
	print(mapListIndex)

func _on_next_map_button_pressed():
	mapListIndex += 1
	
	if mapListIndex >= mapPathsList.size():
		mapListIndex = 0
	
	selectedMap = mapPathsList[mapListIndex]
	mapName.text = mapNamesList[mapListIndex]

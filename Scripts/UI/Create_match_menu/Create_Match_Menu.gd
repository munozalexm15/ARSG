extends PanelContainer

@onready var lobbyName : TextEdit = $VBoxContainer/TextEdit

@onready var mapName : Label = $VBoxContainer/MapSelectorContainer/TextureRect/Label

var mapList = [""]

@onready var playerQuantityOption : OptionButton = $VBoxContainer/OptionButton3
@onready var gamemodeOption : OptionButton = $VBoxContainer/OptionButton
@onready var privacityOption : OptionButton = $VBoxContainer/OptionButton2


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_create_room_button_pressed():
	var roomDict = {"lobbyName" : lobbyName.text, "mapName": mapName.text, "playerQuantity" : playerQuantityOption.text.to_int(), "lobbyType" : privacityOption.text, "gameMode" : gamemodeOption.text}
	
	if privacityOption.text == "PUBLIC":
		roomDict["lobbyType"] = SteamMultiplayerPeer.LOBBY_TYPE_PUBLIC
	if privacityOption.text == "FRIENDS":
		roomDict["lobbyType"] = SteamMultiplayerPeer.LOBBY_TYPE_FRIENDS_ONLY
	if privacityOption.text == "PRIVATE":
		roomDict["lobbyType"] = SteamMultiplayerPeer.LOBBY_TYPE_PRIVATE
	
	Network.host_server(roomDict)
	GlobalData.isOnlineMatch = true
	LoadScreenHandler.next_scene = "res://Scenes/Levels/initial_level.tscn"

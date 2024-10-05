extends Control

@onready var lobbiesList : GridContainer = $PanelContainer/VBoxContainer/LobbiesList

@export var lobbyJoinMenuNode := NodePath()
@onready var joinLobbyMenu = get_node(lobbyJoinMenuNode)

@onready var refreshListButton : Button = $PanelContainer/VBoxContainer/RefreshListButton

@onready var animPlayer : AnimationPlayer = $AnimationPlayer
@onready var noLobbiesMSG: Label = $PanelContainer/VBoxContainer/Label

var refRowContainer = null
var index = 0

var selectedLobby = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	refreshListButton.visible = false
	Steam.lobby_match_list.connect(on_lobby_mach_list)


func open_lobby_list():
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	Steam.addRequestLobbyListStringFilter("obviousNotSpacewarButGameName", "ARSG", Steam.LOBBY_COMPARISON_EQUAL)
	Steam.requestLobbyList()
	
func on_lobby_mach_list(lobbies : Array):
	joinLobbyMenu.visible = false
	animPlayer.play("open_list")
	visible = true
	if lobbiesList.get_child_count() > 0:
		for lobbyButton in lobbiesList.get_children():
			lobbyButton.queue_free()
		
	if lobbies.size() > 0:
		noLobbiesMSG.visible = false
	
	if lobbies.size() == 0:
		noLobbiesMSG.visible = true
		
	for lobby in lobbies:
		var lobby_name = Steam.getLobbyData(lobby, "name")
		var user_count = Steam.getNumLobbyMembers(lobby)
			
		if lobby_name.length() > 10:
			lobby_name = lobby_name.substr(0, 5) + "..."
		
		var button: Button = Button.new()
		button.set_text(str(lobby_name + " (" + str(user_count) + " / " + str(Steam.getLobbyMemberLimit(lobby) ) + ")"))
		button.set_size(Vector2(100,5))
		button.connect("pressed", Callable(self, "show_lobby_data").bind(lobby))
		lobbiesList.add_child(button)

func show_lobby_data(lobby):
	if joinLobbyMenu.joinRoomButton.is_connected("pressed", Callable(self, "load_map_and_get_lobby")):
		joinLobbyMenu.joinRoomButton.disconnect("pressed", Callable(self, "load_map_and_get_lobby"))
	
	joinLobbyMenu.lobby = lobby
	joinLobbyMenu.joinRoomButton.connect("pressed", Callable(self, "load_map_and_get_lobby").bind(lobby))
	joinLobbyMenu.mapName.text = Steam.getLobbyData(lobby, "map")
	joinLobbyMenu.lobbyName.text = Steam.getLobbyData(lobby, "name")
	joinLobbyMenu.gamemodeName.text = Steam.getLobbyData(lobby, "gamemode")
	joinLobbyMenu.playerCount.text = str(Steam.getNumLobbyMembers(lobby)) + " / " + str(Steam.getLobbyMemberLimit(lobby))
	if Steam.getLobbyData(lobby, "mapImage") != "":
		joinLobbyMenu.mapImage.texture = load(Steam.getLobbyData(lobby, "mapImage"))
	
	if lobby != selectedLobby:
		if not joinLobbyMenu.visible:
			animPlayer.play("show_lobby_details")
		selectedLobby = lobby
	else:
		animPlayer.play("show_lobby_details", -1, -1, true)
		selectedLobby = -1

func _on_visibility_changed():
	if visible:
		open_lobby_list()
	else:
		visible = false
		if refreshListButton:
			refreshListButton.visible = false
			noLobbiesMSG.visible = false

func load_map_and_get_lobby(lobby):
	
	if Steam.getNumLobbyMembers(lobby) >= Steam.getLobbyMemberLimit(lobby):
		return
		
	Network.lobby_id = lobby
	LoadScreenHandler.next_scene = Steam.getLobbyData(lobby, "mapPath")
	get_tree().change_scene_to_packed(LoadScreenHandler.loading_screen)


func _on_refresh_list_button_pressed() -> void:
	open_lobby_list()
	refreshListButton.focus_mode = Control.FOCUS_NONE

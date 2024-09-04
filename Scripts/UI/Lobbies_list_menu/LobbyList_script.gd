extends Control

@onready var lobbiesList : GridContainer = $PanelContainer/LobbiesList

@export var lobbyJoinMenuNode := NodePath()
@onready var joinLobbyMenu = get_node(lobbyJoinMenuNode)

@onready var animPlayer : AnimationPlayer = $AnimationPlayer

var refRowContainer = null
var index = 0

var selectedLobby = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	Steam.lobby_match_list.connect(on_lobby_mach_list)


func open_lobby_list():
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	Steam.requestLobbyList()
	
func on_lobby_mach_list(lobbies):
	joinLobbyMenu.visible = false
	animPlayer.play("open_list")
	visible = true
	if lobbiesList.get_child_count() > 0:
		for lobbyButton in lobbiesList.get_children():
			lobbyButton.queue_free()
	
	for lobby in lobbies:
		var lobby_name = Steam.getLobbyData(lobby, "name")
		var user_count = Steam.getNumLobbyMembers(lobby)
		
		if lobby_name.length() >= 14:
			lobby_name = lobby_name.substr(0, 5) + "..."
		
		var button: Button = Button.new()
		button.set_text(str(lobby_name + " (" + str(user_count) + " / " + str(Steam.getLobbyMemberLimit(lobby) ) + ")"))
		button.set_size(Vector2(100,5))
		button.connect("pressed", Callable(self, "show_lobby_data").bind(lobby))
		lobbiesList.add_child(button)

func show_lobby_data(lobby):
	joinLobbyMenu.lobby = lobby
	if not joinLobbyMenu.joinRoomButton.is_connected("pressed", Callable(Network, "join_server")):
		joinLobbyMenu.joinRoomButton.connect("pressed", Callable(Network, "join_server").bind(lobby))
	joinLobbyMenu.mapName.text = Steam.getLobbyData(lobby, "map")
	joinLobbyMenu.lobbyName.text = Steam.getLobbyData(lobby, "name")
	joinLobbyMenu.gamemodeName.text = Steam.getLobbyData(lobby, "gamemode")
	joinLobbyMenu.playerCount.text = str(Steam.getNumLobbyMembers(lobby)) + " / " + str(Steam.getLobbyMemberLimit(lobby))
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

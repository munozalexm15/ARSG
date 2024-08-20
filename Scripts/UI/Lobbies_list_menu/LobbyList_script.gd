extends ScrollContainer

@onready var lobbiesList : VBoxContainer = $LobbiesList

@export var lobbyJoinMenuNode := NodePath()
@onready var joinLobbyMenu : PanelContainer = get_node(lobbyJoinMenuNode)

# Called when the node enters the scene tree for the first time.
func _ready():
	Steam.lobby_match_list.connect(on_lobby_mach_list)
	joinLobbyMenu.connect("showLobbies", open_lobby_list)


func open_lobby_list():
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	Steam.requestLobbyList()
	
func on_lobby_mach_list(lobbies):
	visible = true
	if lobbiesList.get_child_count() > 0:
		for lobbyButton in lobbiesList.get_children():
			lobbyButton.queue_free()
	
	for lobby in lobbies:
		var lobby_name = Steam.getLobbyData(lobby, "name")
		var user_count = Steam.getNumLobbyMembers(lobby)
		
		var button: Button = Button.new()
		button.set_text(str(lobby_name + "(Players: " + str(user_count) + ")"))
		button.set_size(Vector2(100,5))
		button.connect("pressed", Callable(self, "show_lobby_data").bind(lobby))
		lobbiesList.add_child(button)

func show_lobby_data(lobby):
	visible = false
	joinLobbyMenu.lobby = lobby
	joinLobbyMenu.mapName.text = Steam.getLobbyData(lobby, "map")
	joinLobbyMenu.lobbyName.text = Steam.getLobbyData(lobby, "name")
	joinLobbyMenu.gamemodeName.text = Steam.getLobbyData(lobby, "gamemode")
	joinLobbyMenu.playerCount.text = str(Steam.getNumLobbyMembers(lobby)) + " / " + str(Steam.getLobbyMemberLimit(lobby))
	joinLobbyMenu.visible = true

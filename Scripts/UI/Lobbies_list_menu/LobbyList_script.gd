extends ScrollContainer

@onready var lobbiesList : VBoxContainer = $LobbiesList

# Called when the node enters the scene tree for the first time.
func _ready():
	Steam.lobby_match_list.connect(on_lobby_mach_list)


func open_lobby_list():
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	Steam.requestLobbyList()
	
func on_lobby_mach_list(lobbies):
	for lobby in lobbies:
		var lobby_name = Steam.getLobbyData(lobby, "name")
		var user_count = Steam.getNumLobbyMembers(lobby)
		
		var button: Button = Button.new()
		button.set_text(str(lobby_name + "(Players: " + str(user_count) + ")"))
		button.set_size(Vector2(100,5))
		button.connect("pressed", Callable(Network, "join_server").bind(lobby))
		
		lobbiesList.add_child(button)

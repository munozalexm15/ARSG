extends PanelContainer

@onready var playersList : VBoxContainer = $HBoxContainer/PLAYERS_SideBar

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func get_lobby_data():
	var num_of_members: int = Steam.getNumLobbyMembers(Network.lobby_id)
	
	for member in range(0, num_of_members):
		var member_steam_id = Steam.getLobbyMemberByIndex(Network.lobby_id, member)
		Steam.getPlayerAvatar(Steam.AVATAR_SMALL, member_steam_id)
		
		#Create the horizontal container and add the sprite, name, kills, deaths, etc. to the row
		var playerRow : HBoxContainer = HBoxContainer.new()
		playersList.add_child(playerRow)
	
		var playerName : Label = Label.new()
		playerName.text = Steam.getFriendPersonaName(member_steam_id)
		playerName.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		playerName.horizontal_alignment =HORIZONTAL_ALIGNMENT_CENTER
		playerRow.add_child(playerName)
		
		var playerKills : Label = Label.new()
		playerKills.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		playerKills.horizontal_alignment =HORIZONTAL_ALIGNMENT_CENTER
		playerRow.add_child(playerKills)
		
		var playerDeaths : Label = Label.new()
		playerDeaths.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		playerDeaths.horizontal_alignment =HORIZONTAL_ALIGNMENT_CENTER
		playerRow.add_child(playerDeaths)
		
		for player in Network.game.players:
			var playerData = Network.game.players[player]
			print(playerData)
			playerKills.text = str(playerData["kills"])
			playerDeaths.text = str(playerData["deaths"])

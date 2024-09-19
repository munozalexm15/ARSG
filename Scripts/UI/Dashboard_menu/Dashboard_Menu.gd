extends PanelContainer

@onready var playersList : VBoxContainer = $HBoxContainer/PLAYERS_SideBar/VBoxContainer
@onready var matchStatus : Label = $Label
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

@rpc("any_peer", "call_local", "reliable")
func get_lobby_data():
	for node in playersList.get_children():
		node.queue_free()
		
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
		
		var playerData = Network.game.players["player" + str(Network.peer.get_peer_id_from_steam64(member_steam_id)) ]
		playerKills.text = str(playerData["kills"])
		playerDeaths.text = str(playerData["deaths"])
	
	#if gamemode is FFA
		if Network.gameData["gameMode"] == "FREE FOR ALL":
			#if the person is not you (the other team)
			if multiplayer.get_unique_id() != Network.peer.get_peer_id_from_steam64(member_steam_id) and playerData["kills"] > Network.game.team2GoalProgress :
				Network.game.team2GoalProgress = playerData["kills"]
			if multiplayer.get_unique_id() == Network.peer.get_peer_id_from_steam64(member_steam_id):
				Network.game.team1GoalProgress = playerData["kills"]
		
			if multiplayer.get_unique_id() == Network.peer.get_peer_id_from_steam64(member_steam_id) and playerData["kills"] > Network.game.team2GoalProgress :
				Network.game.team2GoalProgress = playerData["kills"]
	
		if Network.game.team1GoalProgress == Network.game.matchGoal:
			matchStatus.text = Steam.getFriendPersonaName(member_steam_id) + " WINS!"
			#Network.call_deferred("endGame")
			return
		
		elif Network.game.team2GoalProgress == Network.game.matchGoal:
			matchStatus.text = Steam.getFriendPersonaName(member_steam_id) + " WINS!"
			#Network.call_deferred("endGame")
			return
		

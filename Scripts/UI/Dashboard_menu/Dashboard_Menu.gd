extends Control

@onready var playersList : VBoxContainer = $VBoxContainer/DashboardMatch/HBoxContainer/PLAYERS_SideBar/VBoxContainer
@onready var winnerLabel : Label = $VBoxContainer/Label

var youStylebox : StyleBoxFlat = preload("res://Scenes/UI/OverrideStyles/You_in_Scoreboard.tres")
var enemyStylebox : StyleBoxFlat = preload("res://Scenes/UI/OverrideStyles/Enemy_on_Scoreboard.tres")

@onready var gamemodeMap : Label = $VBoxContainer/PanelContainer/HBoxContainer/GamemodeMap
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

@rpc("any_peer", "call_local", "reliable")
func get_lobby_data():
	gamemodeMap.text = str(Network.gameData.get("gameMode") , " | " , Network.gameData.get("mapName"))
	gamemodeMap.uppercase = true
	for node in playersList.get_children():
		node.queue_free()
		
	var num_of_members: int = Steam.getNumLobbyMembers(Network.lobby_id)
	
	for index in range(0, num_of_members):
		var member_steam_id = Steam.getLobbyMemberByIndex(Network.lobby_id, index)
		
		var playerContainer: PanelContainer = PanelContainer.new()
		if member_steam_id == Steam.getSteamID():
			playerContainer.add_theme_stylebox_override("panel", youStylebox)
		else:
			playerContainer.add_theme_stylebox_override("panel", enemyStylebox)
		
		playersList.add_child(playerContainer)
			
		#Create the horizontal container and add the sprite, name, kills, deaths, etc. to the row
		var playerRow : HBoxContainer = HBoxContainer.new()
		playerContainer.add_child(playerRow)
	
		var playerName : Label = Label.new()
		playerName.size_flags_stretch_ratio = 7.5
		playerName.text = Steam.getFriendPersonaName(member_steam_id)
		playerName.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		playerName.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		playerRow.add_child(playerName)
		
		var playerScore : Label = Label.new()
		playerScore.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		playerScore.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		playerRow.add_child(playerScore)
		
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
		playerScore.text = str(playerData['score'])
	
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
			winnerLabel.text = Steam.getFriendPersonaName(member_steam_id) + " WINS!"
			#Network.call_deferred("endGame")
			return
		
		elif Network.game.team2GoalProgress == Network.game.matchGoal:
			winnerLabel.text = Steam.getFriendPersonaName(member_steam_id) + " WINS!"
			#Network.call_deferred("endGame")
			return
		

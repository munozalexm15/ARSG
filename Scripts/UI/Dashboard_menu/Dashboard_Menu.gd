extends Control

@onready var playersList : VBoxContainer = $VBoxContainer/DashboardMatch/HBoxContainer/PLAYERS_SideBar/VBoxContainer
@onready var winnerLabel : Label = $VBoxContainer/Label

var youStylebox : StyleBoxFlat = preload("res://Scenes/UI/OverrideStyles/You_in_Scoreboard.tres")
var enemyStylebox : StyleBoxFlat = preload("res://Scenes/UI/OverrideStyles/Enemy_on_Scoreboard.tres")

@onready var gamemodeMap : Label = $VBoxContainer/PanelContainer/HBoxContainer/GamemodeMap
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func get_lobby_data():
	if Network.peer is OfflineMultiplayerPeer:
		return
	Network.game.players.sort_custom(sort_by_kills)
	gamemodeMap.text = str(Network.gameData.get("gameMode") , " | " , Network.gameData.get("mapName"))
	gamemodeMap.uppercase = true
	
	for node in playersList.get_children():
		node.queue_free()
		
	var num_of_members: int = Steam.getNumLobbyMembers(Network.lobby_id)
	for index in range(0, num_of_members):
		if Network.peer is OfflineMultiplayerPeer:
			return
		var playerData = Network.game.players[index]
		
		var member_steam_id = Network.peer.get_steam64_from_peer_id(int(playerData["id"]))
		
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
		
		playerKills.text = str(playerData["kills"])
		playerDeaths.text = str(playerData["deaths"])
		playerScore.text = str(playerData['score'])
		
		if Network.game.matchTimer.time_left == 0:
			return
	#if gamemode is FFA
		if Network.gameData["gameMode"] == "FACE OFF":
			#if the person is not you (the other team)
			if multiplayer.get_unique_id() != Network.peer.get_peer_id_from_steam64(member_steam_id) and playerData["kills"] > Network.game.team2GoalProgress :
				Network.game.team2GoalProgress = playerData["kills"]
			if multiplayer.get_unique_id() == Network.peer.get_peer_id_from_steam64(member_steam_id):
				Network.game.team1GoalProgress = playerData["kills"]
	
		if Network.game.team1GoalProgress == Network.game.matchGoal:
			if multiplayer.get_unique_id() == 1:
				Network.endGame.rpc(Steam.getFriendPersonaName(member_steam_id) + " WINS!") 
				await get_tree().create_timer(5).timeout
				if multiplayer.get_unique_id() == 1:
					Network.close_match()
					get_tree().change_scene_to_file("res://Scenes/Menu/main_menu.tscn")
		
		elif Network.game.team2GoalProgress == Network.game.matchGoal:
			if multiplayer.get_unique_id() == 1:
				Network.endGame.rpc(Steam.getFriendPersonaName(member_steam_id) + " WINS!") 
				await get_tree().create_timer(5).timeout
				if multiplayer.get_unique_id() == 1:
					Network.close_match()
					get_tree().change_scene_to_file("res://Scenes/Menu/main_menu.tscn")

func sort_by_kills(a, b):
	if a["score"] > b["score"]:
		return true 
	else:
		return false

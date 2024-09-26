extends Node

var lobby_id = 0
var peer : MultiplayerPeer = null
var game : MP_Map = null

var gameData : Dictionary = {}

func _ready():
	peer = OfflineMultiplayerPeer.new()
	OS.set_environment("SteamAppID", str(480))
	OS.set_environment("SteamGameID", str(480))
	Steam.steamInitEx()
	Steam.initAuthentication()
	#si se crea un lobby
	
	#Steam.lobby_joined.connect(_on_lobby_joined)
	Steam.lobby_chat_update.connect(_on_lobby_chat_update)
	
	#si se mete un cliente (para sincronizar la sala)
	#multiplayer.peer_connected.connect(client_connected_to_server)
	
	tree_exiting.connect(force_exit_handler)
	
	Steam.p2p_session_connect_fail.connect(client_connection_failed_handler)

func _process(_delta):
	Steam.run_callbacks()

# --------------------------------------- STEAM MULTIPLAYER PEER AND STEAM HOST / CLIENT WORKFLOW ----------------

func host_server(roomData : Dictionary):
	peer = SteamMultiplayerPeer.new()
	peer.lobby_created.connect(on_lobby_created)
	
	gameData = roomData
	peer.refuse_new_connections = false
	peer.create_lobby(roomData["lobbyType"], roomData["playerQuantity"])
	#Steam.createLobby(Steam.LOBBY_TYPE_PUBLIC, roomData["playerQuantity"])
	multiplayer.multiplayer_peer = peer

func on_lobby_created(connection, id):
	if connection:
		lobby_id = id
		Steam.setLobbyData(lobby_id, "name", gameData["lobbyName"])
		Steam.setLobbyData(lobby_id, "gamemode", gameData["gameMode"])
		Steam.setLobbyData(lobby_id, "map", gameData["mapName"])
		Steam.setLobbyData(lobby_id, "mapPath", gameData["mapPath"])
		Steam.setLobbyData(lobby_id, "goal", str(gameData["goal"]) )
		Steam.setLobbyData(lobby_id, "time", str(gameData["time"]) )
		Steam.setLobbyJoinable(lobby_id, true)
		print("Player has started a server with id: ", multiplayer.get_unique_id())
		LoadScreenHandler.next_scene = gameData["mapPath"]
		get_tree().change_scene_to_packed(LoadScreenHandler.loading_screen)

func join_server(id):
	peer.refuse_new_connections = false
	peer = SteamMultiplayerPeer.new()
	#Steam.joinLobby(id)
	peer.connect_lobby(id)
	multiplayer.multiplayer_peer = peer
	lobby_id = id

func _on_lobby_joined(id : int, _permissions: int, _locked : bool, response : int) -> void:
	if response != Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		var fail_reason: String
		match response:
			Steam.CHAT_ROOM_ENTER_RESPONSE_DOESNT_EXIST: fail_reason = "This lobby no longer exists."
			Steam.CHAT_ROOM_ENTER_RESPONSE_NOT_ALLOWED: fail_reason = "You don't have permission to join this lobby."
			Steam.CHAT_ROOM_ENTER_RESPONSE_FULL: fail_reason = "The lobby is now full."
			Steam.CHAT_ROOM_ENTER_RESPONSE_ERROR: fail_reason = "Uh... something unexpected happened!"
			Steam.CHAT_ROOM_ENTER_RESPONSE_BANNED: fail_reason = "You are banned from this lobby."
			Steam.CHAT_ROOM_ENTER_RESPONSE_LIMITED: fail_reason = "You cannot join due to having a limited account."
			Steam.CHAT_ROOM_ENTER_RESPONSE_CLAN_DISABLED: fail_reason = "This lobby is locked or disabled."
			Steam.CHAT_ROOM_ENTER_RESPONSE_COMMUNITY_BAN: fail_reason = "This lobby is community locked."
			Steam.CHAT_ROOM_ENTER_RESPONSE_MEMBER_BLOCKED_YOU: fail_reason = "A user in the lobby has blocked you from joining."
			Steam.CHAT_ROOM_ENTER_RESPONSE_YOU_BLOCKED_MEMBER: fail_reason = "A user you have blocked is in the lobby."
			
		print("Failed to join this chat room: %s" % fail_reason)
	
	lobby_id = id
	print("Your unique id is " , multiplayer.get_unique_id())
	
#En esta funcion (cliente) añadir carga de mapa, añadir señal al loadscreenhandler y cuando cargue el mapa emitir la señal y entonces llamar a un funcion similar a esta
@rpc("any_peer", "call_local", "reliable")
func client_connected_to_server(id):
	#Notificar al host que se acaba de unir un nuevo jugador, y enviarle al cliente todos los datos de los jugadores y la partida (armas, muertes, bajas, etc.)
	if multiplayer.get_unique_id() == 1:
		print("A new client has joined with id :" , id)
		player_joined.rpc_id(id, id, game.players, game.matchTimer.time_left, game.team1GoalProgress, game.team2GoalProgress, gameData)
		return
	
	#Notificar al cliente que se acaba de unir
	print("Client has connected to server with id: ", multiplayer.get_unique_id())

func _on_lobby_chat_update(_this_lobby_id: int, change_id: int, _making_change_id: int, chat_state: int) -> void:
	# Get the user who has made the lobby change
	var changer_name: String = Steam.getFriendPersonaName(change_id)
	
	# If a player has joined the lobby
	if chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_ENTERED:
		print("%s has joined the lobby." % changer_name)
	# Else if a player has left the lobby
	elif chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_LEFT:
		print("%s has left the lobby." % changer_name)
		if game.matchGoal == game.team1GoalProgress or game.matchGoal == game.team2GoalProgress:
			return
		game.dashboardMatch.get_lobby_data()
	# Else if a player has been kicked
	elif chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_KICKED:
		print("%s has been kicked from the lobby." % changer_name)
	# Else if a player has been banned
	elif chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_BANNED:
		print("%s has been banned from the lobby." % changer_name)
	# Else there was some unknown change
	else:
		print("%s did... something." % changer_name)
		

#--------------------------------------------------- GAME MECHANICS (ADDING PLAYER, ETC.)--------------------------------

@rpc("any_peer", "call_remote")
func player_joined(id, players_dict, time_left, team1Progress, team2Progress, hostGameData):
	#if its the host -> ignore
	if id == 1:
		return
	
	gameData = hostGameData
	game.matchGoal = gameData.get("goal") 
	game.matchTime = gameData.get("time")
	game.matchTimer.wait_time = time_left
	game.matchTimer.start()
	game.team1GoalProgress = team1Progress
	game.team2GoalProgress = team2Progress
	
	game.players = players_dict
	#for each player, get its data and set its respective nodes / configuration
	for index in game.players_node.get_child_count():
		var player : Player = game.players_node.get_child(index)
		var player_data = players_dict[index]
		game.set_player_data.rpc_id(multiplayer.get_unique_id(), player.name.to_int(), player.name)
		game.request_game_info.rpc_id(multiplayer.get_unique_id(), player_data)
	
	game.init_player.rpc(multiplayer.get_unique_id())
	await game.player_spawner.spawned
	game.set_player_data.rpc(multiplayer.get_unique_id(), id)
	show_all_players.rpc_id(multiplayer.get_unique_id())

@rpc("any_peer", "call_local", "reliable")
func player_left(_id):
	for p in game.players_node.get_children():
		if p.name == str(_id):
			p.queue_free()
	
	var playerIndex = 0
	for index in game.players.size():
		var playerData = game.players[index]
		if playerData["id"] == str(_id):
			playerIndex = index
	
	game.players.remove_at(playerIndex)

@rpc("call_remote", "any_peer")
func update_client_Data():
	var PauseScene = load("res://Scenes/UI/Pause_Menu/pause_menu.tscn")
	var weaponSelectionScene = load("res://Scenes/UI/Team_Selection/Team_selection.tscn")
	
	for player in game.players_node.get_children():
		if player.name == str(multiplayer.get_unique_id()):
			continue
		var node : Node3D = Node3D.new() 
		node.name = player.name
		game.add_child(node)
		
		var pauseMenu : Pause_Menu = PauseScene.instantiate()
		pauseMenu.name = str(player.name.to_int())
		pauseMenu.set_multiplayer_authority(player.name.to_int())
		node.add_child(pauseMenu)
		player.pauseMenu = pauseMenu
		
		var weaponSelection : WeaponSelection_Menu = weaponSelectionScene.instantiate()
		weaponSelection.name = str(player.name.to_int())
		weaponSelection.player = player
		weaponSelection.set_multiplayer_authority(player.name.to_int())
		node.add_child(weaponSelection)
		player.weaponSelectionMenu = weaponSelection
	
@rpc("any_peer", "call_local", "reliable")
func update_teams(identifier, newTeam):
	for player in game.players_node.get_children():
		if str(identifier) == player.name:
			player.team = newTeam

@rpc("any_peer", "call_local", "reliable")
func updatePlayerWeapon(identifier, weaponScenePath : String):
	var weapon : PackedScene = load(weaponScenePath)
	var weaponSpawned : Weapon = weapon.instantiate()
	for player : Player in game.players_node.get_children():
		if str(identifier) == player.name:
			
			weaponSpawned.set_multiplayer_authority(player.name.to_int())
			
			weaponSpawned.position = weaponSpawned.weaponData.weaponSpawnPosition
			weaponSpawned.handsNode = player.arms.get_path()
			
			if player.arms.weaponHolder.get_child_count() > 0:
				player.arms.weaponHolder.remove_child(player.arms.weaponHolder.get_child(0))
			player.arms.weaponHolder.add_child(weaponSpawned) 
			player.arms.actualWeapon = player.arms.weaponHolder.get_child(0)
			player.eyes.get_child(0).setRecoil(player.arms.actualWeapon.weaponData.recoil)
			player.arms.state_machine.transition_to("SwappingWeapon")
			player.visible = true
			player.weaponSelectionMenu.visible = false
			
			for index in game.players.size():
				var playerDict = game.players[index]
				if playerDict["id"] == str(identifier):
					playerDict["weaponName"] = weaponSpawned.weaponData.name
					playerDict["weaponScenePath"] = weaponScenePath

@rpc("any_peer", "call_local")
func show_all_players():
	for player : Player in game.players_node.get_children():
		if player.arms.weaponHolder.get_child_count() > 0:
			player.visible = true


# ------------------------------------------ EXIT LOBBY ---------------------------------------------------
func leave_lobby() -> void:
	if lobby_id == 0:
		return
	Steam.leaveLobby(lobby_id)
	for x in Steam.getNumLobbyMembers(lobby_id):
		var member_steam_id = Steam.getLobbyMemberByIndex(lobby_id, x)
		if member_steam_id != Steam.getSteamID():
			Steam.closeP2PSessionWithUser(member_steam_id)
	
	lobby_id = 0
	peer.disconnect_peer(multiplayer.get_unique_id(), true)
	#peer.close()
	peer = OfflineMultiplayerPeer.new()
	peer.refuse_new_connections = true

@rpc("any_peer", "reliable", "call_local")
func exit_and_return_to_main_menu():
	Network.player_left.rpc(multiplayer.get_unique_id())
	Network.leave_lobby()
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED 
	get_tree().change_scene_to_file("res://Scenes/Menu/main_menu.tscn")

func close_match():
	var lobbyId = Network.lobby_id 
	for x in Steam.getNumLobbyMembers(lobbyId):
		var member_steam_id = Steam.getLobbyMemberByIndex(lobbyId, x)
		var peer_id= Network.peer.get_peer_id_from_steam64(member_steam_id)
		
		if peer_id == 1:
			continue
		
		Network.exit_and_return_to_main_menu.rpc_id(peer_id)
		Network.peer.disconnect_peer(peer_id, true)
		
	Steam.leaveLobby(lobbyId)
	Network.peer.close()
	Network.peer = OfflineMultiplayerPeer.new()
	Network.peer.refuse_new_connections = true
	
@rpc("any_peer", "call_local", "reliable")
func endGame(winnerText: String):
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	for player : Player in game.players_node.get_children():
		player.pauseMenu.visible = false
		player.pauseMenu.set_process(false)
		
	game.dashboardMatch.visible = true
	game.dashboardMatch.winnerLabel.text = winnerText
	game.dashboardMatch.winnerLabel.visible = true

#----------------------------------------------- FORCING EXIT (TREE QUITING / EXITING) -----------------------------

func force_exit_handler():
	if peer is SteamMultiplayerPeer and (peer.get_connection_status() == peer.CONNECTION_CONNECTED or peer.get_connection_status() == peer.CONNECTION_CONNECTING):
		if multiplayer.get_unique_id() == 1:
			endGame.rpc("HOST ENDED THE MATCH")
			await get_tree().create_timer(5).timeout
			close_match()
		else:
			Network.player_left.rpc(multiplayer.get_unique_id())
			Network.leave_lobby()


#--------------------------------------------- CONNECTION ERROR HANDLING -------------------------------------------------
func client_connection_failed_handler(steam_id: int, session_error: int) -> void:
	# If no error was given
	if session_error == 0:
		print("WARNING: Session failure with %s: no error given" % steam_id)

	# Else if target user was not running the same game
	elif session_error == 1:
		print("WARNING: Session failure with %s: target user not running the same game" % steam_id)

	# Else if local user doesn't own app / game
	elif session_error == 2:
		print("WARNING: Session failure with %s: local user doesn't own app / game" % steam_id)

	# Else if target user isn't connected to Steam
	elif session_error == 3:
		print("WARNING: Session failure with %s: target user isn't connected to Steam" % steam_id)

	# Else if connection timed out
	elif session_error == 4:
		print("WARNING: Session failure with %s: connection timed out" % steam_id)

	# Else if unused
	elif session_error == 5:
		print("WARNING: Session failure with %s: unused" % steam_id)

	# Else no known error
	else:
		print("WARNING: Session failure with %s: unknown error %s" % [steam_id, session_error])

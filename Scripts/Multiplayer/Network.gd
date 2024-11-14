extends Node

var lobby_id = 0
var peer : MultiplayerPeer = null
var game : MP_Map = null

var gameData : Dictionary = {}
var role = ""

func _ready():
	peer = OfflineMultiplayerPeer.new()
	OS.set_environment("SteamAppID", str(480))
	OS.set_environment("SteamGameID", str(480))
	#si se mete un cliente (para sincronizar la sala)
	
	tree_exiting.connect(force_exit_handler)

# --------------------------------------- STEAM MULTIPLAYER PEER AND STEAM HOST / CLIENT WORKFLOW ----------------

#--------------------------------------------------- GAME MECHANICS (ADDING PLAYER, ETC.)--------------------------------

@rpc("any_peer", "call_remote")
func player_joined(id, players_dict, time_left, team1Progress, team2Progress, hostGameData):
	#if its the host -> ignore
	if id == 1:
		return
	
	#recursivo para low-end pc's que la llamada asyncrona llega antes que la propia carga del mapa y variables correspondientes
	if !game:
		await get_tree().create_timer(1).timeout
		player_joined(id, players_dict, time_left, team1Progress, team2Progress, hostGameData)
		
	gameData = hostGameData
	game.matchGoal = hostGameData.get("goal") 
	game.matchTime = hostGameData.get("time")
	game.matchTimer.wait_time = time_left
	game.matchTimer.start()
	game.team1GoalProgress = team1Progress
	game.team2GoalProgress = team2Progress
	
	game.players = players_dict
	#for each player, get its data and set its respective nodes / configuration
	for index in game.players_node.get_child_count():
		var player : Player = game.players_node.get_child(index)
		var player_data = players_dict[index]
		#game.set_player_data.rpc_id(multiplayer.get_unique_id(), player.name.to_int(), player.name)
		game.request_game_info.rpc_id(multiplayer.get_unique_id(), player_data)
	
	#game.init_player.rpc(multiplayer.get_unique_id())
	#game.set_player_data.rpc(multiplayer.get_unique_id(), id)
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
		if str(identifier) == str(player.name):
			weaponSpawned.set_multiplayer_authority(player.name.to_int())
			weaponSpawned.position = weaponSpawned.weaponData.weaponSpawnPosition
			weaponSpawned.handsNode = player.arms.get_path()
			if player.is_dead:
				player.can_heal = true
				for weaponInHolder in player.arms.weaponHolder.get_children():
					player.arms.weaponHolder.remove_child(weaponInHolder)
				
				player.arms.weaponHolder.add_child(weaponSpawned) 
				player.arms.actualWeapon = player.arms.weaponHolder.get_child(0)
				player.arms.actual_weapon_index = 0
				player.arms.actualWeapon.being_used = true
				player.eyes.get_child(0).setRecoil(player.arms.actualWeapon.weaponData.recoil)
				weaponSpawned.weaponData.reserveAmmo = weaponSpawned.weaponData.defaultReserveAmmo
				weaponSpawned.weaponData.bulletsInMag = weaponSpawned.weaponData.magSize
				player.arms.state_machine.transition_to("SwappingWeapon")
				player.health = 100
				player.is_dead = false
			
			#modify only the visibility (locally) of the other player
			if player.weaponSelectionMenu:
				player.hud.animationPlayer.play("swap_gun", -1, 100.0, false)
				player.weaponSelectionMenu.visible = false
			
			for index in game.players.size():
				var playerDict = game.players[index]
				if playerDict["id"] == str(identifier):
					playerDict["classSelectedPath"] = weaponScenePath 
					playerDict["actualWeaponName"] = weaponSpawned.weaponData.name
					playerDict["actualWeaponPath"] = weaponScenePath
					playerDict["primaryWeaponName"] = weaponSpawned.weaponData.name
					playerDict["primaryWeaponPath"] = weaponScenePath
			
			player.arms.actualWeapon.leftArm.get_active_material(0).albedo_texture = player.arms.handsAssignedTexture
			player.arms.actualWeapon.rightArm.get_active_material(0).albedo_texture = player.arms.handsAssignedTexture
			player.arms.grenade.leftHand.get_active_material(0).albedo_texture = player.arms.handsAssignedTexture
			player.arms.grenade.rightHand.get_active_material(0).albedo_texture= player.arms.handsAssignedTexture
			
			player.visible = true
			
@rpc("any_peer", "call_local")
func show_all_players():
	for player : Player in game.players_node.get_children():
		if player.arms.weaponHolder.get_child_count() > 0:
			player.visible = true
		else:
			player.visible = false


# ------------------------------------------ EXIT LOBBY ---------------------------------------------------
func leave_lobby() -> void:
	if lobby_id == 0:
		return
	
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
	pass
	
@rpc("any_peer", "call_local", "reliable")
func endGame(winnerText: String):
	pass

#----------------------------------------------- FORCING EXIT (TREE QUITING / EXITING) -----------------------------

func force_exit_handler():
	pass


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


func findPlayer(id) -> Player:
	for p : Player in game.players_node.get_children():
		if str(id) == p.name:
			return p
	return null

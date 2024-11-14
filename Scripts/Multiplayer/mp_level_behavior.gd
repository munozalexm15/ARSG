class_name MP_Map
extends Node3D

var players : Array = []
var death_count = 0

@export var PlayerScene = preload("res://Scenes/Characters/Main_character.tscn")
@export var PauseScene = preload("res://Scenes/UI/Pause_Menu/pause_menu.tscn")
@export var weaponSelectionScene = preload("res://Scenes/UI/Team_Selection/Team_selection.tscn")

@export var team1SkinsResources : Array
@export var team2SkinsResources : Array


@onready var players_node = $FadeShader/SubViewport/DitheringShader/SubViewport
@onready var menus_node = $PauseMenusNode
@onready var weaponSelections_node = $weaponSelectionNode
@onready var bullets_node : Node3D= $BulletsParent

@onready var interactables_node : Node3D = $InteractablesParent
@onready var spawnPoints_node : Node3D= $SpawnPoints
@onready var killFeedVBox = $KillFeed/KillFeedHistory

@onready var pauseMenuSpawner : MultiplayerSpawner = $pauseMenuSpawner
@onready var playerSpawner : MultiplayerSpawner = $PlayerSpawner
@onready var weaponSelectionSpawner : MultiplayerSpawner = $weaponSelectionSpawner

@export var lightArray : Array


var matchGoal = 0
var team1GoalProgress = 0
var team2GoalProgress = 0
var matchTime = 0
var matchTimeLeft = 0

@onready var mortarSound : AudioStreamPlayer = $ASP_MortarSound

var textDisplayPos = 0
var textDisplayArray: Array = ["¡Buenas!, Esto que ves aquí es el inicio de mi primer juego 3D en Godot.

Inició como un mini proyecto para hacer un FPS con estetica retro y familiarizarme aún más con Godot (Ya que el último proyecto que hice con el fue TRACEUR y era en 2D), pero a la larga decidí no quedarme con las ganas y ser más ambicioso: Iba a hacer un juego multijugador.", 

"A lo largo del desarrollo aprendí mucho de todos los aspectos que componen a un videojuego: Sonidos, animaciones, feedback al jugador, responsividad, diseño de niveles, licencias, y mucho más.

El apartado online fue fácil de implementar gracias a GodotSteam, un plugin que permitia utilizar las funcionalidades de Steam / SteamWorks y así jugar con otros jugadores que también tuviesen Steam.", 

"Finalmente, después de unos duros y largos 6 meses (A mediados de octubre de 2024) lancé en Itch.io 'ARSG', un juego de accion en primera persona multijugador en línea pensado para enfrentamientos 1vs1 con un amigo. 

En fin, eso es todo. ¡El campo de tiro es todo tuyo! Puedes pegar unos tiros antes de volver al castillo ¿No?

...¡Ah si!, Si quieres volver al castillo solo tienes que salir del campo de tiro y tomar la salida de la izquierda."]

# Called when the node enters the scene tree for the first time.
func _ready():
	var chatAction = InputEventKey.new()
	chatAction.keycode = GlobalData.configData.get_value("Controls", "Open Chat", 84)
	weaponSelectionSpawner.spawn_function = Callable(self, "set_player_weaponSelection")
	pauseMenuSpawner.spawn_function = Callable(self, "set_player_pause_menu")
	
	
	Network.game = self
	Network.role = "Host"
	GlobalData.configurationUpdated.connect(set_new_chat_subtext)

	#multiplayer.connected_to_server.connect(loadGame)
	
	if Network.role == "Host":
		generatePlayer(multiplayer.get_unique_id())
		#uiSpawner.spawn_function = Callable(self, "set_player_data")
		#uiSpawner.spawn()
		#init_player.rpc(multiplayer.get_unique_id())
		#set_player_data.rpc(multiplayer.get_unique_id(), multiplayer.get_unique_id())

	lightError()
	
func lightError():
	var randomTime = randi_range(10, 25)
	await get_tree().create_timer(randomTime).timeout
	players_node.get_child(0).camera.shakeStrength = randf_range(0.01, 0.02)
	mortarSound.play()
	
	for i in range(3):
		var randomLightOutTime = randf_range(0, 0.5)
		var random_index = randi_range(0, lightArray.size() -1)
		var lightNode = get_node(lightArray[random_index])
		lightNode.visible = false
		await get_tree().create_timer(randomLightOutTime).timeout
		lightNode.visible = true
	
	lightError()
	
func _process(delta: float) -> void:
	if $SubViewport/AnimationPlayer.is_playing() and $SubViewport/AnimationPlayer.current_animation == "TYPEWRITER_TEXT":
		$AudioStreamPlayer3D.play()

func generatePlayer(id):
	var weaponSelectionInstance = weaponSelectionSpawner.spawn(id)
	var pauseMenuInstance = pauseMenuSpawner.spawn(id)
	var playerInstance = $"FadeShader/SubViewport/DitheringShader/SubViewport/1"
	playerInstance.hud.visible = false
	
	playerInstance.pauseMenu = pauseMenuInstance
	pauseMenuInstance.player = playerInstance
	playerInstance.weaponSelectionMenu = weaponSelectionInstance
	weaponSelectionInstance.player = playerInstance
	
	setAuthToPlayer(playerInstance.name, pauseMenuInstance.name, weaponSelectionInstance.name, id)

func setAuthToPlayer(playernode_Name, pauseMenuNode_Name, weaponSelectionNode_Name, newId):
	var playerInstance : Player = $"FadeShader/SubViewport/DitheringShader/SubViewport/1"
	var menuInstance = menus_node.get_node("./" + pauseMenuNode_Name)
	var selectionInstance = weaponSelections_node.get_node("./" + weaponSelectionNode_Name)
	
	#loop recursivo para ir esperando a que el player esté listo
	if not playerInstance or not menuInstance or not selectionInstance:
		await get_tree().create_timer(1).timeout
		setAuthToPlayer(playernode_Name, pauseMenuNode_Name, weaponSelectionNode_Name, newId)
		return
	
	playerInstance.global_position = random_spawn()
	playerInstance.set_multiplayer_authority(newId, true)
	playerInstance.visible = false
	
	playerInstance.name = str(newId)
	menuInstance.set_multiplayer_authority(newId, true)
	menuInstance.name = str(newId) + "pauseMenu"
	selectionInstance.set_multiplayer_authority(newId, true)
	selectionInstance.name = str(newId) + "weaponSelection"
	
	playerInstance.global_position = random_spawn()
	playerInstance.state_machine.process_mode = PROCESS_MODE_DISABLED
	
	playerInstance.pauseMenu = menuInstance
	menuInstance.player = playerInstance
	playerInstance.weaponSelectionMenu = selectionInstance
	selectionInstance.player = playerInstance
	#var team : int = randi_range(0, 1)
	var skin : PlayerSkin = null
	
	skin = team1SkinsResources.pick_random()

		
	#esto se tiene que pasar a un rpc con el identifier del player y deberia de estar ya hecho
	playerInstance.arms.handsAssignedTexture = skin.rightHandSkin
	playerInstance.arms.handsAssignedTexture = playerInstance.arms.handsAssignedTexture.duplicate()
	#
	var headMaterialDuplicate = playerInstance.player_body.playerMesh.get_active_material(0).duplicate()
	playerInstance.player_body.playerMesh.set_surface_override_material(0, headMaterialDuplicate)
	var bodyMaterialDuplicte =  playerInstance.player_body.playerMesh.get_active_material(1).duplicate()
	playerInstance.player_body.playerMesh.set_surface_override_material(1, bodyMaterialDuplicte)
	
	playerInstance.player_body.playerMesh.get_active_material(0).set_shader_parameter("albedo", skin.BodySkin)
	playerInstance.player_body.playerMesh.get_active_material(1).set_shader_parameter("albedo", skin.HeadSkin)
	
func loadGame():
	Network.client_connected_to_server(multiplayer.get_unique_id())

func  _input(_event: InputEvent) -> void:
	pass

func init_player(peer_id):
	pass

func set_player_pause_menu(peer_id):
	var pauseMenu : Pause_Menu = PauseScene.instantiate()
	pauseMenu.name = str(peer_id) + "pauseMenu"
	pauseMenu.set_multiplayer_authority(peer_id)
	return pauseMenu

func set_player_weaponSelection(peer_id):
	var weaponSelection : WeaponSelection_Menu = weaponSelectionScene.instantiate()
	weaponSelection.name = str(peer_id) + "weaponSelection"
	weaponSelection.set_multiplayer_authority(peer_id)
	return weaponSelection

##Creating and assigning a team selection, class selection and pause menus to a player
func set_player_data(peer_id, playerName):
	var node : Node3D = Node3D.new()
	node.name = str(playerName)
	add_child(node)
	
	var player : Player = null
	for p in players_node.get_children():
		if p.name == str(playerName):
			player = p
	
	player.visible = false
	player.global_position = random_spawn()
	
	var pauseMenu : Pause_Menu = PauseScene.instantiate()
	pauseMenu.name = str(peer_id) + "pauseMenu"
	pauseMenu.set_multiplayer_authority(peer_id) 
	node.add_child(pauseMenu)
	player.pauseMenu = pauseMenu
	pauseMenu.player = player
	
	var weaponSelection : WeaponSelection_Menu = weaponSelectionScene.instantiate()
	weaponSelection.name = str(peer_id) + "weaponMenu"
	weaponSelection.player = player
	weaponSelection.set_multiplayer_authority(peer_id)
	node.add_child(weaponSelection)
	player.weaponSelectionMenu = weaponSelection
	
	#skin assignation
	if Network.gameData["gameMode"] == "FACE OFF":
		#var team : int = randi_range(0, 1)
		var skin : PlayerSkin = null
		if players.size() == 1:
			skin = team1SkinsResources.pick_random()
		else:
			skin = team2SkinsResources.pick_random()
		
		player.arms.handsAssignedTexture = skin.rightHandSkin
		
		player.player_body.playerMesh.get_active_material(0).set_shader_parameter("albedo", skin.BodySkin)
		player.player_body.playerMesh.get_active_material(1).set_shader_parameter("albedo", skin.HeadSkin)

func replace_weapon_content(weapon : Node3D):
	for child : Node in weapon.get_children():
		child.queue_free()

func random_spawn():
	var safeSpawnPoints = []
	var spawnPointFar = null
	
	var spawnPoint = spawnPoints_node.get_child(0)
	return spawnPoint.position

#load client data from the other players already in the match.
func request_game_info(player_dict : Dictionary):
	for index in players_node.get_child_count():
		var player : Player = players_node.get_child(index)
		if player.name == player_dict["id"]:
			if player_dict.has("primaryWeaponPath"):
				var weaponScene : PackedScene = load(player_dict["primaryWeaponPath"])
				var weapon : Weapon = weaponScene.instantiate()
				weapon.handsNode = player.arms.get_path()
				player.arms.weaponHolder.add_child(weapon)
				
			if player_dict.has("secondaryWeaponPath"):
				var weaponScene : PackedScene = load(player_dict["secondaryWeaponPath"])
				var weapon : Weapon = weaponScene.instantiate()
				weapon.handsNode = player.arms.get_path()
				player.arms.weaponHolder.add_child(weapon)
			
			for weapon : Weapon in player.arms.weaponHolder.get_children():
				if weapon.weaponData.name == player_dict["actualWeaponName"]:
					player.arms.actualWeapon = weapon

func _on_match_timer_timeout():
	if multiplayer.get_unique_id() == 1:
		Network.endGame(str("THE WINNER IS " , players[0]["name"]) ) 
		await get_tree().create_timer(5).timeout
		if multiplayer.get_unique_id() == 1:
			Network.close_match()
			get_tree().change_scene_to_file("res://Scenes/Menu/main_menu.tscn")

func add_kill_to_killFeed(killer_name : String, weaponImage : CompressedTexture2D, dead_name : String):
	var playerRow : HBoxContainer = HBoxContainer.new()
	killFeedVBox.add_child(playerRow)
	
	var killerPlayerName : Label = Label.new()
	killerPlayerName.text = killer_name
	playerRow.add_child(killerPlayerName)
	
	var weaponKillerImage : TextureRect = TextureRect.new()
	weaponKillerImage.texture = weaponImage
	weaponKillerImage.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	playerRow.add_child(weaponKillerImage)
	
	var deadPlayerName : Label = Label.new()
	deadPlayerName.text = dead_name
	playerRow.add_child(deadPlayerName)
	
	await get_tree().create_timer(4).timeout
	playerRow.queue_free()


func _on_foce_exit_button_pressed() -> void:
	if get_tree().paused:
		get_tree().paused = false
	
	#CLIENT LEAVING MATCH
	if multiplayer.get_unique_id() != 1:
		Network.player_left(multiplayer.get_unique_id())
		Network.leave_lobby()
		get_tree().change_scene_to_file("res://Scenes/Menu/main_menu.tscn")


func _on_chat_text_gutter_added() -> void:
	pass

func set_new_chat_subtext():
	pass


func _on_lxndrw_tpose_show_text(text: Variant) -> void:
	$SubViewport/RichTextLabel.visible = true
	$SubViewport/AnimationPlayer.play("TYPEWRITER_TEXT")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "TYPEWRITER_TEXT":
		if textDisplayPos == textDisplayArray.size() -1:
			textDisplayPos = 0
		else:
			await get_tree().create_timer(5).timeout
			$SubViewport/AnimationPlayer.play("TYPEWRITER_ERASE_TEXT")
	
	if anim_name == "TYPEWRITER_ERASE_TEXT":
		textDisplayPos += 1
		$SubViewport/AnimationPlayer.play("TYPEWRITER_TEXT")


func _on_animation_player_animation_started(anim_name: StringName) -> void:
	if anim_name == "TYPEWRITER_TEXT":
		$SubViewport/RichTextLabel.text = textDisplayArray[textDisplayPos]

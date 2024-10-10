extends Control

@export var loadingShader : ShaderMaterial

var loadedScene = null

@onready var loadStatus : Label = $VBoxContainer/LOAD_status
@onready var errorMSG : Label = $VBoxContainer/ErrorMessage

# Called when the node enters the scene tree for the first time.
func _ready():
	LoadScreenHandler.connect("errorLoading", on_error_load)
	loadingShader.set_shader_parameter("percentage", 0)
	ResourceLoader.load_threaded_request(LoadScreenHandler.next_scene)
	Steam.initRelayNetworkAccess()
	Steam.lobby_joined.connect(_on_lobby_joined)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var progress = []
	ResourceLoader.load_threaded_get_status(LoadScreenHandler.next_scene, progress)
	loadingShader.set_shader_parameter("percentage", progress[0])
	
	if progress[0] == 1:
		var packed_scene = ResourceLoader.load_threaded_get(LoadScreenHandler.next_scene)
		if Network.peer.get_class() != "OfflineMultiplayerPeer":
			start_map(packed_scene)
		else:
			loadingShader.set_shader_parameter("percentage", 100)
			loadedScene = packed_scene
			Network.join_server(Network.lobby_id)
			loadStatus.text = "JOINING ROOM..."


func start_map(packed_scene : PackedScene):
	#host joining
	get_tree().change_scene_to_packed(packed_scene)

func _on_lobby_joined(_id : int, _permissions: int, _locked : bool, response : int) -> void:
	if response != Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS or Network.peer.get_connection_status() != Network.peer.ConnectionStatus.CONNECTION_CONNECTED:
		var fail_reason: String
		match response:
			Steam.CHAT_ROOM_ENTER_RESPONSE_DOESNT_EXIST: fail_reason = "ERROR: This lobby no longer exists. Returning to menu."
			Steam.CHAT_ROOM_ENTER_RESPONSE_NOT_ALLOWED: fail_reason = "ERROR: You don't have permission to join this lobby. Returning to menu."
			Steam.CHAT_ROOM_ENTER_RESPONSE_FULL: fail_reason = "The lobby is now full. Returning to menu."
			Steam.CHAT_ROOM_ENTER_RESPONSE_ERROR: fail_reason = "Uh... something unexpected happened! Returning to menu."
			Steam.CHAT_ROOM_ENTER_RESPONSE_BANNED: fail_reason = "You are banned from this lobby. Sorry. Returning to menu."
			Steam.CHAT_ROOM_ENTER_RESPONSE_LIMITED: fail_reason = "You cannot join due to having a limited account. Returning to menu."
			Steam.CHAT_ROOM_ENTER_RESPONSE_CLAN_DISABLED: fail_reason = "This lobby is locked or disabled. Returning to menu."
			Steam.CHAT_ROOM_ENTER_RESPONSE_COMMUNITY_BAN: fail_reason = "This lobby is community locked. Returning to menu."
			Steam.CHAT_ROOM_ENTER_RESPONSE_MEMBER_BLOCKED_YOU: fail_reason = "A user in the lobby has blocked you from joining. Sorry. Returning to menu."
			Steam.CHAT_ROOM_ENTER_RESPONSE_YOU_BLOCKED_MEMBER: fail_reason = "A user you have blocked is in the lobby. Bullet dodged. Returning to menu."
			
		print("Failed to join this chat room: %s" % fail_reason)
		Network.leave_lobby()
		
		LoadScreenHandler.errorLoading.emit(fail_reason)
	else:
		Network.role = "Client"
		get_tree().change_scene_to_packed(loadedScene)

func join_room(_id):
	if Network.peer.get_connection_status() == 2:
		get_tree().change_scene_to_packed(loadedScene)
	else:
		get_tree().change_scene_to_file("res://Scenes/Menu/main_menu.tscn")

func on_error_load(fail_message : String):
	errorMSG.text = fail_message
	errorMSG.visible = true
	await get_tree().create_timer(4).timeout
	get_tree().change_scene_to_file("res://Scenes/Menu/main_menu.tscn")

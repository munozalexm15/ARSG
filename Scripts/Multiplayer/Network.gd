extends Node

var server = null
var client = null
var connect_ip = "127.0.0.1"
var default_PORT = 55455
var unique_id = -1
var players = 0

var game = null

func _ready():
	multiplayer.peer_connected.connect(player_joined)
	multiplayer.peer_disconnected.connect(player_left)

func host_server():
	server = ENetMultiplayerPeer.new()
	server.create_server(default_PORT)
	multiplayer.multiplayer_peer = server
	unique_id = server.get_unique_id()
	players+=1
	
func join_server():
	client = ENetMultiplayerPeer.new()
	client.create_client(connect_ip, default_PORT)
	multiplayer.multiplayer_peer = client
	unique_id = client.get_unique_id()

func player_joined(id):
	if id != 1:
		game.init_player(id)
	

func player_left(_id):
	pass

func load_map():
	pass

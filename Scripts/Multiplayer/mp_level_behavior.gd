class_name MP_Map
extends Node3D

const PORT = 9999
var enet_peer = ENetMultiplayerPeer.new()


@export var PlayerScene = preload("res://Scenes/Characters/Main_character.tscn")
@export var PauseScene = preload("res://Scenes/UI/Pause_Menu/pause_menu.tscn")

@onready var players_node = $FadeShader/SubViewport/DitheringShader/SubViewport
@onready var bullets_node = $BulletsParent

@onready var interactables_node = $InteractablesParent

# Called when the node enters the scene tree for the first time.
func _ready():
	if is_multiplayer_authority():
		init_player.rpc(Network.unique_id)
	
	Network.game = self

func start_game():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

@rpc("any_peer", "call_local")
func init_player(peer_id):
	var player : Player = PlayerScene.instantiate()
	player.name = str(peer_id)
	player.set_multiplayer_authority(peer_id)
	players_node.add_child(player)
	#player.pauseMenu = playerMenu

@rpc("any_peer", "call_local", "reliable")
func update_players_equipment(player_id : int, NewWeaponHolder : Node3D):
	print("new weapon Holder weapons")
	for player in players_node.get_children():
		for weapon : Weapon in NewWeaponHolder.get_children():
			print(player.multiplayer.get_unique_id() , " : ", weapon.weaponData.name)
	
	#for player in players_node.get_children():
		#if player.name == str(player_id):
			#player.arms.weaponHolder.replace_by(NewWeaponHolder)

func replace_weapon_content(weapon : Node3D):
	for child : Node in weapon.get_children():
		child.queue_free()

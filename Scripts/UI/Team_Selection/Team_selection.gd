class_name TeamSelection_Menu
extends Control


var player : Player

# Called when the node enters the scene tree for the first time.
func _ready():
	if not is_multiplayer_authority(): 
		visible = false
	
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_rebirth_team_button_pressed():
	Network.update_teams.rpc(multiplayer.get_unique_id(), "REBIRTH")
	visible = false
	player.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN


func _on_dsf_team_button_pressed():
	visible = false
	player.visible = true
	Network.update_teams.rpc(multiplayer.get_unique_id(), "DSF")
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	


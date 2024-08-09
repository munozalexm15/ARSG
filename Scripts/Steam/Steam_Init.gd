extends Node3D

var mainMenu_Scene : PackedScene = preload("res://Scenes/Menu/main_menu.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	OS.set_environment("SteamAppID", str(480))
	OS.set_environment("SteamGameID", str(480))
	Steam.steamInitEx()
	var mainmenuNode = mainMenu_Scene.instantiate()
	get_tree().root.add_child.call_deferred(mainmenuNode)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	Steam.run_callbacks()

extends Node3D

var mainMenu_Scene : PackedScene = preload("res://Scenes/Menu/main_menu.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	var mainmenuNode = mainMenu_Scene.instantiate()
	get_tree().root.add_child.call_deferred(mainmenuNode)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

extends Control

@onready var mapName : Label = $PanelContainer/VBoxContainer/MapSelectorContainer/TextureRect/Label
@onready var gamemodeName : Label = $PanelContainer/VBoxContainer/VBoxContainer/Label8
@onready var playerCount : Label = $PanelContainer/VBoxContainer/VBoxContainer/Label9
@onready var lobbyName : Label = $PanelContainer/VBoxContainer/HBoxContainer/Label3

@onready var joinRoomButton : Button = $PanelContainer/VBoxContainer/Button

var lobby = 0

signal showLobbies

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func _on_button_pressed():
	visible = false
	showLobbies.emit()

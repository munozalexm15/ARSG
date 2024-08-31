extends Control

@onready var mapName : Label = $VBoxContainer/MapSelectorContainer/TextureRect/Label
@onready var gamemodeName : Label = $VBoxContainer/Label8
@onready var playerCount : Label = $VBoxContainer/Label9
@onready var lobbyName : Label = $VBoxContainer/HBoxContainer/Label3

@onready var joinRoomButton : Button = $VBoxContainer/Button

var lobby = 0

signal showLobbies

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func _on_button_pressed():
	visible = false
	showLobbies.emit()

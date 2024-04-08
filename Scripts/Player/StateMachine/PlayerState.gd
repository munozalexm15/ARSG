#Clase "puente" para adaptar el owner al tipo de objeto que sea el jugador (en mi caso CharacterBody2D).
#Esto se hace para que a la hora de tratar con el objeto sepamos que metodos podemos utilizar (velocity, etc...)

class_name PlayerState
extends State

var player: Player

func _ready() -> void:
	await owner.ready
	player = owner as CharacterBody3D
	assert(player != null)

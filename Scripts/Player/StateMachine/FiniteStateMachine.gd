#StateMachine class

class_name StateMachine
extends Node

signal transitioned(state_name, old_state)

@export var initial_state := NodePath()
@onready var state : State = get_node(initial_state)

var old_state : State = null

func _ready():
	await owner.ready
	for child in get_children():
		child.state_machine  = self
	state.enter()
	
func _process(delta : float):
	state.update(delta)

func _unhandled_input(event : InputEvent):
	state.handle_input(event)

func _physics_process(delta : float):
	state.physics_update(delta)

func transition_to(state_name : String, msg : Dictionary = {}):
	if not has_node(state_name):
		return
		
	old_state = state
	
	state.exit()
	state = get_node(state_name)
	state.enter(msg)
	emit_signal("transitioned", state.name, old_state.name)

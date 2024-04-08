#Equivalent "interface" for State in GDScript 
class_name State
extends Node

var state_machine = null

#Handles input from '_unhandled_input' callback
func handle_input(_event : InputEvent) -> void:
	pass

#Equivalent to _process callback
func update(_delta : float) -> void:
	pass

#Equivalent to 'physics_process' callback
func physics_update(_delta: float) -> void:
	pass

#-----TRANSITION FUNCTIONS FOR SWAPPING BETWEEN STATES----
#They are handled in the StateMachine

#Enter state function
func enter(_msg := {}) -> void:
	pass

#Exit state function
func exit() -> void:
	pass

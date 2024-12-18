class_name State extends Node

var fsm: StateMachine
signal state_entered()
signal state_exited()

func enter() -> void:
	state_entered.emit()

func exit(next_state: String) -> void:
	fsm.change_to(next_state)
	state_exited.emit()

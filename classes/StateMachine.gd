class_name StateMachine extends Node

var current_state: Object

var history: Array[String] = []
var states: Dictionary = {}
signal changed_state_to(name_of_state: String)

func _ready() -> void:
	for state in get_children():
		state.fsm = self
		states[state.name] = state
		if current_state:
			remove_child(state)
		else:
			current_state = state
	current_state.enter()


func change_to(state_name: String) -> void:
	history.append(current_state.name)
	set_state(state_name)


func back() -> void:
	if history.size() > 0:
		set_state(history.pop_back())


func set_state(state_name: String) -> void:
	remove_child(current_state)
	current_state = states[state_name]
	add_child(current_state)
	current_state.enter()
	changed_state_to.emit(state_name)

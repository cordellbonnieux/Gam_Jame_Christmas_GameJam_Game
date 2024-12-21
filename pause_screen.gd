extends CanvasLayer

@onready var fsm: StateMachine = $StateMachine
@onready var pause_menu: Container = $pause_menu
@onready var die_menu: Container = $win_menu
@onready var win_menu: Container = $die_menu

signal main_menu

func pause() -> void:
	if fsm.current_state.name == "off":
		fsm.current_state.exit("pause")

func unpause() -> void:
	if fsm.current_state.name == "pause":
		fsm.current_state.exit("off")


func _on_off_state_entered() -> void:
	if pause_menu.visible:
		pause_menu.visible = false
	if die_menu.visible:
		die_menu.visible = false
	if win_menu.visible:
		win_menu.visible = false

func _on_off_state_exited() -> void:
	pass # Replace with function body.

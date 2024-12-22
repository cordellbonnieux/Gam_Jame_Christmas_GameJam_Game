extends CanvasLayer

@onready var fsm: StateMachine = $StateMachine
@onready var pause_menu: Container = $pause_menu
@onready var die_menu: Container = $win_menu
@onready var win_menu: Container = $die_menu

signal main
signal again

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if fsm.current_state.name == "pause":
			fsm.current_state.exit("off")
		elif fsm.current_state.name == "off":
			fsm.current_state.exit("pause")

func pause() -> void:
	if fsm.current_state.name == "off":
		fsm.current_state.exit("pause")
	elif fsm.current_state.name == "pause":
		fsm.current_state.exit("off")

func win(gifts: int, time_s: int) -> void:
	fsm.current_state.exit("win")
	print("gifts collected: ", gifts, " , time in s: ", time_s)
	get_tree().paused = true
	
func die(gifts: int, time_s: int) -> void:
	fsm.current_state.exit("win")
	print("gifts collected: ", gifts, " , time in s: ", time_s)
	get_tree().paused = true

func quit() -> void:
	pause()
	main.emit()

func _on_pause_state_entered() -> void:
	get_tree().set_deferred("paused", true)
	pause_menu.visible = true


func _on_pause_state_exited() -> void:
	pause_menu.visible = false
	get_tree().paused = false

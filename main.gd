extends Node2D

var game_scene: PackedScene = preload("res://levels/theres_snow_time_like_the_present.tscn")
@onready var main_menu: CanvasLayer = $main_menu
@onready var cutscene: CanvasLayer = $cut_scene
@onready var game: Node2D = $game
@onready var fsm: StateMachine = $StateMachine

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cane"):
		if fsm.current_state.name == "menu":
			fsm.current_state.exit("cutscene")
		elif fsm.current_state.name == "cutscene":
			fsm.current_state.exit("game")

func return_to_main() -> void:
	clean_up_game()
	fsm.current_state.exit("menu")

func restart_game() -> void:
	clean_up_game()
	fsm.current_state.exit("game")

func clean_up_game() -> void:
	game.get_child(0).get_node("player").main.disconnect(return_to_main)
	game.get_child(0).get_node("player").again.disconnect(restart_game)
	game.remove_child(game.get_child(0))

func _on_menu_state_entered() -> void:
	if main_menu && !main_menu.visible:
		main_menu.visible = true


func _on_menu_state_exited() -> void:
	if main_menu && main_menu.visible:
		main_menu.visible = false


func _on_cutscene_state_entered() -> void:
	if !cutscene.visible:
		cutscene.visible = true


func _on_cutscene_state_exited() -> void:
	if cutscene.visible:
		cutscene.visible = false


func _on_game_state_entered() -> void:
	if !game.visible:
		game.visible = true
	game.add_child(game_scene.instantiate())
	game.get_child(0).get_node("player").main.connect(return_to_main)
	game.get_child(0).get_node("player").again.connect(restart_game)


func _on_game_state_exited() -> void:
	pass

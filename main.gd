extends Node2D

var game_scene: PackedScene = preload("res://levels/theres_snow_time_like_the_present.tscn")
@onready var main_menu: CanvasLayer = $main_menu
@onready var pause_menu: CanvasLayer = $pause_menu
@onready var cutscene: CanvasLayer = $cut_scene
@onready var game: Node2D = $game
@onready var win_menu: CanvasLayer = $win_menu
@onready var die_menu: CanvasLayer = $die_menu
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

func pause_game(pause: bool = true) -> void:
	get_tree().paused = pause


func _on_menu_state_entered() -> void:
	if !main_menu.visible:
		main_menu.visible = true


func _on_menu_state_exited() -> void:
	if main_menu.visible:
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


func _on_game_state_exited() -> void:
	if game.visible:
		game.visible = false
	game.remove_child(game.get_child(0))

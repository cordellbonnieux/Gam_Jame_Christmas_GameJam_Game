extends Node2D

@onready var main_menu: CanvasLayer = $main_menu
@onready var pause_menu: CanvasLayer = $pause_menu
@onready var cut_scene: CanvasLayer = $cut_scene
@onready var game: Node2D = $TheresSnowTimeLikeThePresent

func _ready() -> void:
	#TODO freeze the game until start
	pass

extends VBoxContainer

@onready var gift_ui: RichTextLabel = $bg/MarginContainer/content/info/VBoxContainer/gifts/gifts/amount
@onready var time_ui: RichTextLabel = $bg/MarginContainer/content/info/VBoxContainer/time/time/time
signal main

func _on_quit_pressed() -> void:
	get_tree().paused = false
	main.emit()

func add_stats(g: int, s: String) -> void:
	gift_ui.text = str(g)
	time_ui.text = s
	

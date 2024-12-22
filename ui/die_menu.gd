extends VBoxContainer

@onready var time_ui: RichTextLabel = $bg/MarginContainer/content/info/VBoxContainer/time/time/time
signal main
signal again

func _on_quit_pressed() -> void:
	get_tree().paused = false
	main.emit()


func add_time(s: String) -> void:
	time_ui.text = s
	

func _on_again_pressed() -> void:
	get_tree().paused = false
	again.emit()

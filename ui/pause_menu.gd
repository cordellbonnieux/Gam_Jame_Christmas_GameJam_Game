extends VBoxContainer

signal resume
signal quit

func _on_resume_pressed() -> void:
	resume.emit()


func _on_quit_pressed() -> void:
	quit.emit()

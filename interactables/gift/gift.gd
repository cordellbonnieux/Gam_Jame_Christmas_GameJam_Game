extends Area2D

signal picked_up

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.add_gifts(1)
		picked_up.emit()
		queue_free()

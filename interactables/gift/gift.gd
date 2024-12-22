extends Area2D

signal picked_up

func _process(delta: float) -> void:
	if get_overlapping_bodies().size() > 0:
		for body in get_overlapping_bodies():
			_on_body_entered(body)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.add_gifts(1)
		picked_up.emit()
		queue_free()

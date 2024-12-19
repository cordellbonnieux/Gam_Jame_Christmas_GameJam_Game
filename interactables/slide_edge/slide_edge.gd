extends Node2D

@onready var end: Node2D = $zip_post

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.zip(end, false)

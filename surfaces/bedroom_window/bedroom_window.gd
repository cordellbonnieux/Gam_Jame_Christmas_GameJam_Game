extends Node2D
@onready var col: CollisionShape2D = $ledge/CollisionShape2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		col.set_deferred("disabled", true)


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		col.set_deferred("disabled", false)

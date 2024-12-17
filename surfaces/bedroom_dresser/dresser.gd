extends Node2D

@onready var top_collider: CollisionShape2D = $top/CollisionShape2D

func _on_hide_top_on_collision_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		top_collider.set_deferred("disabled", true)

func _on_hide_top_on_collision_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		top_collider.set_deferred("disabled", false)

extends Node2D

@onready var collider: CollisionShape2D = $StaticBody2D/CollisionShape2D


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		collider.set_deferred("disabled", true)


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		collider.set_deferred("disabled", false)

extends Area2D

@export var destination: Area2D

func latch() -> Vector2:
	return destination.global_position

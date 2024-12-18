extends Area2D

@export var destination: Area2D = null

func latch() -> Vector2:
	if destination:
		return destination.global_position
	else:
		return Vector2.ZERO

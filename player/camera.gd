extends Camera2D

@export var follow_target: CharacterBody2D
@export var follower_bg: Sprite2D

func _physics_process(delta: float) -> void:
	global_position = follow_target.global_position
	follower_bg.global_position = global_position

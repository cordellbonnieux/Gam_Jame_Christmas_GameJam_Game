extends Area2D
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func hook() -> void:
	anim.play("hook_on")

func unhook() -> void:
	anim.play("hook_off")

func _on_animated_sprite_2d_animation_finished() -> void:
	anim.play("idle")
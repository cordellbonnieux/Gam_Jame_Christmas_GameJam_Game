extends Area2D

@onready var anim_plr: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	anim_plr.play("spin")


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.add_sugar(randf_range(3, 13))
		queue_free()

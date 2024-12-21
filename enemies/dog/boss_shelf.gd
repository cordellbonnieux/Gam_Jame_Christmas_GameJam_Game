extends StaticBody2D

var candy_scene: PackedScene = preload("res://interactables/perppermint/peppermint_candy.tscn")
#TODO make a shell for candy

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		if body.fsm.current_state.name == "dazed" || body.fsm.current_state.name == "charging":
			var candy: Area2D = candy_scene.instantiate()
			candy.position = Vector2(96, 64)
			call_deferred("add_child", candy)

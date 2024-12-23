extends AnimatedSprite2D

@export var player: CharacterBody2D

func _ready() -> void:
	play()

func _process(delta: float) -> void:
	if player.fsm.current_state.name == "zipping":
		visible = false
	else:
		visible = true

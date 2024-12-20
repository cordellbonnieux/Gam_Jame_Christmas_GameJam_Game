extends RigidBody2D

func _ready() -> void:
	$gift/CollisionShape2D.set_deferred("disabled", true)
	if randi() % 2:
		apply_central_impulse(Vector2(100,0))
	else:
		apply_central_impulse(Vector2(-100,0))


func _physics_process(_delta: float) -> void:
	rotation = 0


func _on_gift_picked_up() -> void:
	queue_free()


func _on_timer_timeout() -> void:
	$gift/CollisionShape2D.set_deferred("disabled", false)
	freeze = true
	#NOTE the only real problem here is that if the gift falls for more than 1.5 seconds, it will freeze mid-air

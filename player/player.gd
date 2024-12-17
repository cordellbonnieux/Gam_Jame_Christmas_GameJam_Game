extends CharacterBody2D

@export var speed: int = 1200
@export var jump_speed: int = -1800
var gravity: int = 4000
@export_range(0.0, 1.0) var friction: float = 0.1
@export_range(0.0 , 1.0) var acceleration: float = 0.25


func _physics_process(delta):
	velocity.y += gravity * delta
	var dir = Input.get_axis("left", "right")
	if dir != 0:
		velocity.x = lerp(velocity.x, dir * speed, acceleration)
	else:
		velocity.x = lerp(velocity.x, 0.0, friction)

	move_and_slide()
	if Input.is_action_just_pressed("up") and is_on_floor():
		velocity.y = jump_speed

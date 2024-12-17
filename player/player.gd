extends CharacterBody2D

@export var speed: int = 1200
@export var jump_speed: int = -1800
var gravity: int = 4000
var zipping: bool = false
var zip_dest: Vector2
@export_range(0.0, 1.0) var friction: float = 0.1
@export_range(0.0 , 1.0) var acceleration: float = 0.25
@onready var detection_area: Area2D = $detection_area


func _physics_process(delta):	
	if Input.is_action_just_pressed("up") && (is_on_floor() || zipping):
		velocity.y = jump_speed
		zipping = false
		print("stopit")
	elif zipping:
		if abs(zip_dest - global_position).x > 1 && abs(zip_dest - global_position).y > 1:
			velocity = lerp(velocity, (zip_dest - global_position).normalized() * speed, acceleration * 2)
			print(velocity)
		else:
			zipping = false
			print("stopit")
	else:
		velocity.y += gravity * delta
		var dir = Input.get_axis("left", "right")
		if dir != 0:
			velocity.x = lerp(velocity.x, dir * speed, acceleration)
		else:
			velocity.x = lerp(velocity.x, 0.0, friction)

	move_and_slide()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("latch"):
		for area in detection_area.get_overlapping_areas():
			if area.is_in_group("latch"):
				zip_dest = area.latch()
				zipping = true
				return
	elif event.is_action_pressed("hit"):
		pass

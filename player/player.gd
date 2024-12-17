extends CharacterBody2D
# player

var health: int = 3
@export var speed: int = 1200
@export var jump_speed: int = -1800
var gravity: int = 4000
var zipping: bool = false
var zip_dest: Vector2
@export_range(0.0, 1.0) var friction: float = 0.1
@export_range(0.0 , 1.0) var acceleration: float = 0.25
@onready var detection_area: Area2D = $detection_area
@onready var attack_ray: RayCast2D =  $RayCast2D
@onready var cooldown_timer: Timer = $cooldown


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
			
		#NOTE cordie you know this is bad practice!!!
		#TODO sync up anims 
		if dir == -1:
			attack_ray.target_position.x = -300
		elif dir == 1:
			attack_ray.target_position.x = 300

	move_and_slide()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("latch"):
		for area in detection_area.get_overlapping_areas():
			if area.is_in_group("latch"):
				zip_dest = area.latch()
				zipping = true
				return
	elif event.is_action_pressed("hit"):
		#NOTE this is the attack
		if cooldown_timer.is_stopped() && attack_ray.get_collider() && attack_ray.get_collider().is_in_group("enemy"):
			attack_ray.get_collider().damage(1)
			cooldown_timer.start()
			

func damage(amount: int) -> void:
	health -= amount
	print("ouch")
	if health <= 0:
		print("die!")

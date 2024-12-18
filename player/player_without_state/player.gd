extends CharacterBody2D
# player

# TODO add candy meter, the higher it is the faster you go

var health: int = 3
@export var speed: int = 100
@export var jump_speed: int = -200
var sugar_level: int = 0
var gravity: int = 300
# yikes what a mess!
var zipping: bool = false #TODO replace w/ state machine?
var hooked: bool = false
var current_hook: Area2D = null
var zip_dest: Vector2
var ray_length: int
@export_range(0.0, 1.0) var friction: float = 0.1
@export_range(0.0 , 1.0) var acceleration: float = 0.25
@onready var detection_area: Area2D = $detection_area
@onready var attack_ray: RayCast2D =  $RayCast2D
@onready var cooldown_timer: Timer = $cooldown

func _ready() -> void:
	ray_length = $RayCast2D.target_position.x

func _physics_process(delta):	
	if Input.is_action_just_pressed("up") && (is_on_floor() || zipping || hooked):
		velocity.y = jump_speed
		zipping = false
		if hooked:
			hooked = false
			current_hook.unhook()
			velocity *= 1.5
	elif zipping:
		if abs(zip_dest - global_position).x > 1 && abs(zip_dest - global_position).y > 1:
			velocity = lerp(velocity, (zip_dest - global_position).normalized() * (speed + 200), acceleration * 2)
		else:
			zipping = false
	elif hooked:
		#NOTE grapple just below the wreath
		#TODO messy using ints like this
		if abs((current_hook.global_position + Vector2(0, 64)).y - global_position.y) > 1 && abs(current_hook.global_position.x - global_position.x) > 1:
			velocity = lerp(velocity, (current_hook.global_position + Vector2(0, 64) - global_position).normalized() * (speed + sugar_level) * 2, acceleration * 2)
		else:
			velocity = Vector2.ZERO
	else:
		velocity.y += gravity * delta
		var dir = Input.get_axis("left", "right")
		if dir != 0:
			velocity.x = lerp(velocity.x, dir * (speed + sugar_level), acceleration)
		else:
			velocity.x = lerp(velocity.x, 0.0, friction)
			
		#NOTE cordie you know this is bad practice!!!
		#TODO sync up anims 
		if dir == -1:
			attack_ray.target_position.x = -ray_length
		elif dir == 1:
			attack_ray.target_position.x = ray_length

	move_and_slide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("latch"):
		for area in detection_area.get_overlapping_areas():
			if area.is_in_group("latch"):#TODO rename zip?
				if area.destination:
					zip_dest = area.latch()
					zipping = true
					return
			elif area.is_in_group("hook"):
				if hooked:
					hooked = false
					current_hook.unhook()
				else:
					hooked = true
					current_hook = area
					current_hook.hook()
				
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

extends CharacterBody2D

var speed: int = 800
var friction: float = 0.1
var direction: float = 1.0
var gravity: int = 4000
@onready var ray_forward: RayCast2D = $ray_forward
@onready var ray_down_forward: RayCast2D = $ray_floor_checker

func _physics_process(delta):
	if !is_on_floor():
		velocity.y += gravity * delta
		
	elif ray_forward.get_collider():
		if ray_forward.get_collider().is_in_group("player"):
			# attack
			return
		else:
			# change dir
			direction *= -1
			ray_down_forward.target_position.x *= -1
			ray_forward.target_position.x *= -1
			
	elif !ray_down_forward.get_collider():
		# change dir
		direction *= -1
		ray_down_forward.target_position.x *= -1
		ray_forward.target_position.x *= -1
	
	else:
		velocity.x = lerp(velocity.x, direction * speed, friction)
		
	move_and_slide()

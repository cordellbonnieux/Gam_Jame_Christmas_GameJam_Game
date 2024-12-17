extends CharacterBody2D
# enemy mouse

var health: int = 2
var speed: int = 800
var friction: float = 0.1
var direction: float = 1.0
var gravity: int = 4000
var target: CharacterBody2D = null
@onready var ray_forward: RayCast2D = $ray_forward
@onready var ray_down_forward: RayCast2D = $ray_floor_checker
@onready var attack_build_up_timer: Timer = $attack_build_up

func _physics_process(delta):
	if !attack_build_up_timer.is_stopped():
		return
	
	if !is_on_floor():
		velocity.y += gravity * delta
		
	elif ray_forward.get_collider():
		if ray_forward.get_collider().is_in_group("player"):
			# attack
			attack_build_up_timer.start()
			target = ray_forward.get_collider()
			
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
	
func damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		queue_free()


func _on_attack_build_up_timeout() -> void:
	if ray_forward.get_collider() && ray_forward.get_collider() == target:
		target.damage(1)
		print("strike")

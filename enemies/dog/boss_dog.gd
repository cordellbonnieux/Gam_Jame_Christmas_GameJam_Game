extends CharacterBody2D
var health: int = 5
var speed: float = 50.0
var charge_speed: float = 150.0
var acceleration: float = 0.25
@export var target: CharacterBody2D
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var fsm: StateMachine = $StateMachine
@onready var close_ray: RayCast2D = $close_ray
@onready var far_ray: RayCast2D = $far_ray
signal dead

func _process(delta: float) -> void:
	if abs(target.global_position.x - global_position.x) <= 228:
		wake_up() 

func _physics_process(delta: float) -> void:
	if fsm.current_state.name == "moving":
		# go towards target, if target is hooked, then go back and forth in room
		if far_ray.is_colliding() && far_ray.get_collider() == target:
			fsm.current_state.exit("pre-charging")
		
		elif target.fsm.current_state.name == "hooked":
			if close_ray.is_colliding():
				print(close_ray.get_collider())
				velocity.x = lerp(velocity.x, -speed, acceleration)
				flip_x()
			else:
				velocity.x = lerp(velocity.x, speed, acceleration)
			move_and_slide()
		
		else:
			if target.global_position.x > global_position.x:
				velocity.x = lerp(velocity.x, speed, acceleration)
			else:
				print("flippity") #BUG
				velocity.x = lerp(velocity.x, -speed, acceleration)
				flip_x()
			move_and_slide()
		
		
	elif fsm.current_state.name == "charging":
		# if close ray is collling with body in group boss_shelf, then change state to dazed
		if close_ray.is_colliding():
			if close_ray.get_collider() == target:
				target.damage()
			else:
				fsm.current_state.exit("dazed")
		else:
			velocity.x = lerp(velocity.x, charge_speed, acceleration)
			move_and_slide()
		#NOTE maybe stop charging after some distance? or no? maybe too much
		
	elif fsm.current_state.name == "dazed" || fsm.current_state.name == "pre-charging" || fsm.current_state.name == "attacking":
		velocity = Vector2.ZERO

func flip_x() -> void:
	close_ray.target_position.x *= -1
	far_ray.target_position.x *= -1
	anim.scale.x *= -1

func wake_up() -> void:
	if fsm.current_state.name == "sleeping":
		fsm.current_state.exit("moving")


func damage(amount: int = 1) -> void:
	if fsm.current_state.name == "dazed":
		health -= 1
		if health <= 0:
			fsm.current_state.exit("dead")

func attack() -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		pass #launch them away


func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation == "pre-charging":
		fsm.current_state.exit("charging")
		anim.play("charging")
	elif anim.animation == "attacking":
		fsm.current_state.exit("moving")
		

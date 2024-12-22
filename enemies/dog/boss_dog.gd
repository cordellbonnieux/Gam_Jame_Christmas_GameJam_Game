extends CharacterBody2D
var health: int = 15
var speed: float = 50.0
var charge_speed: float = 150.0
var acceleration: float = 0.25
var friction: float = 0.1
var direction: float = 1.0
@export var target: CharacterBody2D
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var fsm: StateMachine = $StateMachine
@onready var close_ray: RayCast2D = $close_ray
@onready var far_ray: RayCast2D = $far_ray
@onready var ass_ray: RayCast2D = $ass_ray
@onready var daze_timer: Timer = $daze_timer
@onready var collider: CollisionShape2D = $CollisionShape2D
@onready var top_collider: CollisionShape2D = $top_dog/CollisionShape2D
@onready var hit_timer: Timer = $hit_timer
signal dead

func _process(_delta: float) -> void:
	if fsm.current_state.name == "dead" || !hit_timer.is_stopped():
		if modulate.a == 1:
			modulate.a = 0.25
		else:
			modulate.a = 1
	elif modulate.a != 1:
		modulate.a = 1
	
	if fsm.current_state.name == "dead":
		return
		
	if fsm.current_state.name == "sleeping" && abs(target.global_position.x - global_position.x) <= 160:
		wake_up()
	
	if (velocity.x > 0 && far_ray.target_position.x < 0) || (velocity.x < 0 && far_ray.target_position.x > 0):
		flip_x()
		

func _physics_process(delta: float) -> void:
	if fsm.current_state.name == "dead":
		if position.x < 500:
			velocity.x += speed * delta * 2
			move_and_slide()
		else:
			velocity = Vector2.ZERO
		
	elif fsm.current_state.name == "seeking":
		if target.fsm.current_state.name == "hooking":
			fsm.current_state.exit("moving")
			
		elif far_ray.is_colliding() && far_ray.get_collider() == target:
			fsm.current_state.exit("pre-charging")
			
		else:
			if target.global_position.x > global_position.x:
				velocity.x += speed * delta
			elif target.global_position.x < global_position.x:
				velocity.x -= speed * delta
			move_and_slide()
			
	elif fsm.current_state.name == "moving":
		if target.fsm.current_state.name != "hooking":
			fsm.current_state.exit("seeking")
			
		else:
			if close_ray.is_colliding():
				flip_x()
				direction *= -1
				
			velocity.x = lerp(velocity.x, direction * speed, friction)
			move_and_slide()
		
	elif fsm.current_state.name == "charging":
		# if close ray is collling with body in group boss_shelf, then change state to dazed
		if close_ray.is_colliding():
			if close_ray.get_collider() == target:
				target.damage()
				fsm.current_state.exit("moving")
			else:
				fsm.current_state.exit("dazed")
		else:
			if far_ray.target_position.x > 0:
				velocity.x = lerp(velocity.x, charge_speed, acceleration)
			else:
				velocity.x = lerp(velocity.x, -charge_speed, acceleration)
			move_and_slide()
		
	elif fsm.current_state.name == "dazed" || fsm.current_state.name == "pre-charging":
		velocity = Vector2.ZERO


func flip_x() -> void:
	close_ray.target_position.x *= -1
	far_ray.target_position.x *= -1
	anim.scale.x *= -1
	ass_ray.target_position.x *= -1


func wake_up() -> void:
	if fsm.current_state.name == "sleeping":
		fsm.current_state.exit("seeking")


func damage(_amount: int = 1) -> void:
	if fsm.current_state.name == "dazed":
		health -= 1
		if health <= 0:
			fsm.current_state.exit("dead")
		else:
			hit_timer.start()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.velocity = Vector2(randf_range(-speed, speed), -speed) * 5
		body.damage()


func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation == "pre-charging":
		fsm.current_state.exit("charging")


func _on_daze_timer_timeout() -> void:
	if fsm.current_state.name != "dead":
		fsm.current_state.exit("seeking")


func _on_precharging_state_entered() -> void:
	anim.play("pre-charging")


func _on_charging_state_entered() -> void:
	anim.play("charging")


func _on_dazed_state_entered() -> void:
	anim.play("dazed")
	daze_timer.start()


func _on_dead_state_entered() -> void:
	if close_ray.target_position.x < 0:
		flip_x()
	target.won()
	top_collider.set_deferred("disabled", true)
	collider.set_deferred("disabled", true)
	anim.play("charging")
	dead.emit()


func _on_moving_state_entered() -> void:
	anim.play("moving")


func _on_seeking_state_entered() -> void:
	anim.play("moving")

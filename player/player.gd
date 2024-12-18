extends CharacterBody2D

var health: int = 3
var sugar_level: int = 0
var speed: int = 100
var jump_speed: int = -200
var zip_speed: int = 400
var gravity: int = 300
var friction: float = 0.1
var acceleration: float = 0.25
var current_hook: Area2D = null
var current_zips: Array[Vector2] = []
@onready var fsm: StateMachine = $StateMachine
@onready var detection_area: Area2D = $detection_area
@onready var attack_ray: RayCast2D =  $RayCast2D
@onready var attack_cooldown_timer: Timer = $attack_cooldown_timer
@onready var knock_back_timer: Timer = $knock_back_timer
@onready var invulnerability_timer: Timer = $invulnerability_timer


func _physics_process(delta):
	if fsm.current_state.name == "dead":
		return
		
	if fsm.current_state.name == "knock-back":
		velocity.x #TODO
		velocity.y
		
	elif Input.is_action_just_pressed("up") && fsm.current_state.name != "falling":
		velocity.y = jump_speed
		if fsm.current_state.name == "hooked":
			current_hook.unhook()
			current_hook = null
		fsm.current_state.exit("falling")
		
	elif fsm.current_state.name == "zipping":
		if abs(current_zips[0] - global_position).x > 1 && abs(current_zips[0] - global_position).y > 1:
			velocity = lerp(velocity, (current_zips[0] - global_position).normalized() * zip_speed, 1)
		else:
			current_zips.pop_front()
			if current_zips.size() <= 0:
				if is_on_floor():
					fsm.current_state.exit("idle")
				else:
					fsm.current_state.exit("falling")
					
	elif fsm.current_state.name == "hooking":
		if abs((current_hook.global_position + Vector2(0, 32)).y - global_position.y) > 1 && abs(current_hook.global_position.x - global_position.x) > 1:
			velocity = lerp(velocity, (current_hook.global_position + Vector2(0, 32) - global_position).normalized() * zip_speed, 1)
		else:
			velocity = Vector2.ZERO
	else:
		velocity.y += gravity * delta
		var dir = Input.get_axis("left", "right")
		if dir != 0:
			#TODO add slipping effect here
			velocity.x = lerp(velocity.x, dir * (speed + sugar_level), acceleration)
			if (dir < 0 && attack_ray.target_position.x > 0) || (dir > 0 && attack_ray.target_position.x < 0):
				attack_ray.target_position.x *= 1
			if is_on_floor():
				if fsm.current_state.name != "running":
					fsm.current_state.exit("running")
			elif fsm.current_state.name != "falling":
				fsm.current_state.exit("falling")
		else:
			velocity.x = lerp(velocity.x, 0.0, friction)
			if is_on_floor():
				if fsm.current_state.name != "idle":
					fsm.current_state.exit("idle")
			elif fsm.current_state.name != "falling":
				fsm.current_state.exit("falling")
	move_and_slide()


func _input(event: InputEvent) -> void:
	if fsm.current_state.name == "dead":
		return
		
	if event.is_action_pressed("latch"):
		for area in detection_area.get_overlapping_areas():
			if area.is_in_group("zip"):
				if area.destinations.size() > 0: #TODO IMPLIMENT THIS
					zip([area.global_position, area.destinations])
					return
			elif area.is_in_group("hook"):
				if fsm.current_state.name == "hooking":
					current_hook.unhook()
					if is_on_floor():
						fsm.current_state.exit("idle")
					else:
						fsm.current_state.exit("falling")
				else:
					current_hook = area
					area.hook()
					fsm.current_state.exit("hooking")
				return
				
	elif event.is_action_pressed("attack"):
		# NOTE notice no attack state, this is intentional, don't add it!
		if attack_cooldown_timer.is_stopped() && attack_ray.get_collider() && attack_ray.get_collider().is_in_group("enemy"):
			attack_ray.get_collider().damage(1)
			attack_cooldown_timer.start()


func damage(amount: int) -> void:
	if fsm.current_state.name != "knock-back" && fsm.current_state.name != "invulnerable":
		health -= amount
		if health <= 0:
			fsm.current_state.exit("dead")
		else:
			fsm.current_state.exit("knock-back")
			knock_back_timer.start()


func zip(global_positions_to_zip_to: Array[Vector2]) -> void:
	current_zips = global_positions_to_zip_to
	fsm.current_state.exit("zipping")


func knock_back_timer_finished() -> void:
	fsm.current_state.exit("idle")

extends CharacterBody2D

var health: int = 3
var sugar_level: float = 0.0
var speed: int = 100
var jump_speed: int = -200
var zip_speed: int = 400
var gravity: int = 300
var friction: float = 0.1
var acceleration: float = 0.25
var current_hook: Area2D = null
var current_zips: Array[Vector2] = []
var invulnerable: bool = false
#var incoming_damage_direction: Vector2i
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var fsm: StateMachine = $StateMachine
@onready var detection_area: Area2D = $detection_area
@onready var attack_ray: RayCast2D =  $RayCast2D
@onready var attack_cooldown_timer: Timer = $attack_cooldown_timer
#@onready var knock_back_timer: Timer = $knock_back_timer
@onready var invulnerability_timer: Timer = $invulnerability_timer
@onready var no_gravity_timer: Timer = $no_gravity_timer
@onready var ui: Dictionary = {
	"sugar": $CanvasLayer/bottom_left/sugar_level,
	"health": $CanvasLayer/top_left/Label,
	"gifts": $CanvasLayer/top_left/Label2,
	"time": $CanvasLayer/top_right/Label2
}

func _ready() -> void:
	ui.sugar.value = sugar_level
	ui.health.text = str(health)

func _process(_delta: float) -> void:
	var step: float = 0.03
	if sugar_level > step:
		sugar_level -= step
		ui.sugar.value = sugar_level


func _physics_process(delta) -> void:
	if fsm.current_state.name == "dead":
		return
		
	#if fsm.current_state.name == "knock-back":
	#	velocity = -zip_speed * incoming_damage_direction
	#	#TODO add blinking effect
		
	elif Input.is_action_just_pressed("up") && fsm.current_state.name != "falling":
		velocity.y = jump_speed
		if fsm.current_state.name == "hooking":
			current_hook.unhook()
			current_hook = null
			no_gravity_timer.start()
			print("start it")
		fsm.current_state.exit("falling")
		
	elif fsm.current_state.name == "zipping" || fsm.current_state.name == "sliding":
		if abs(current_zips[0] - global_position).x > 2 && abs(current_zips[0] - global_position).y > 2:
			velocity = lerp(velocity, (current_zips[0] - global_position).normalized() * zip_speed, 1)
		else:
			current_zips.pop_front()
			if current_zips.size() <= 0:
				if is_on_floor():
					fsm.current_state.exit("idle")
				else:
					fsm.current_state.exit("falling")
					
	elif fsm.current_state.name == "hooking":
		#if abs((current_hook.global_position + Vector2(0, 32)).y - global_position.y) > 1 && abs(current_hook.global_position.x - global_position.x) > 1:
		#	#BUG sometimes causes wierd movement
		#	velocity = lerp(velocity, (current_hook.global_position + Vector2(0, 32) - global_position).normalized() * zip_speed, 1)
		#else:
		velocity = Vector2.ZERO
	else:
		if no_gravity_timer.is_stopped():
			velocity.y += gravity * delta
		else:
			velocity.y = jump_speed
		var dir = Input.get_axis("left", "right")
		if dir != 0:
			#TODO add slipping effect here
			velocity.x = lerp(velocity.x, dir * (speed + sugar_level), acceleration)
			if (dir < 0 && attack_ray.target_position.x > 0) || (dir > 0 && attack_ray.target_position.x < 0):
				attack_ray.target_position.x *= -1
				anim.scale.x *= -1
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
		
	if event.is_action_pressed("cane"):
		for area in detection_area.get_overlapping_areas():
			if area.is_in_group("zip"):
				if area.destination && fsm.current_state.name != "zipping":
					zip(area)
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
					#test
					global_position = area.global_position + Vector2(0,32)
				return
		if attack_cooldown_timer.is_stopped():
			anim.play("attacking")
			attack_cooldown_timer.start()
			if attack_ray.get_collider() && attack_ray.get_collider().is_in_group("enemy"):
				attack_ray.get_collider().damage(1)
				
	#elif event.is_action_pressed("attack"):
	#	# NOTE notice no attack state, this is intentional, don't add it!
	#	if attack_cooldown_timer.is_stopped() && attack_ray.get_collider() && attack_ray.get_collider().is_in_group("enemy"):
	#		attack_ray.get_collider().damage(1)
	#		attack_cooldown_timer.start()


func damage(amount: int) -> void:
	if !invulnerable:
		#incoming_damage_direction = (dmg_abs_pos - global_position).normalized()
		health -= amount
		if health <= 0:
			fsm.current_state.exit("dead")
			ui.health.text = "You're Dead"
		else:
			#fsm.current_state.exit("knock-back")
			#knock_back_timer.start()
			ui.health.text = str(health)
			invulnerability_timer.start()
			invulnerable = true
			modulate = Color(255,0,0,255)


func zip(area: Area2D, zipping: bool = true) -> void:
	current_zips = [area.global_position]
	current_zips.append_array(area.get_destination_global_coords())
	if zipping:
		fsm.current_state.exit("zipping")
	else:
		fsm.current_state.exit("sliding")


func add_sugar(amt: float) -> void:
	if amt > 0:
		sugar_level += amt
		if sugar_level > 100:
			sugar_level = 100
		ui.sugar.value = sugar_level


#func knock_back_timer_finished() -> void:
#	fsm.current_state.exit("idle")


func _on_invulnerability_timer_timeout() -> void:
	invulnerable = false
	modulate = Color(255,255,255,255)


func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation == "attacking":
		anim.play("idle")


func _on_idle_state_entered() -> void:
	if anim:
		anim.play("idle")


func _on_running_state_entered() -> void:
	if anim.animation != "attacking":
		anim.play("running")


func _on_hooking_state_entered() -> void:
	anim.play("hooking")


func _on_zipping_state_entered() -> void:
	anim.play("hooking")


func _on_falling_state_entered() -> void:
	anim.play("falling")


func _on_sliding_state_entered() -> void:
	anim.play("sliding")

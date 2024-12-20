extends CharacterBody2D
var dropable_gift: PackedScene = preload("res://interactables/dropped_gift/dropped_gift.tscn")

var sugar_level: float = 0.0
var gifts: int = 0
var speed: int = 100
var jump_speed: int = -200
var zip_speed: int = 400
var gravity: int = 300
var friction: float = 0.1
var acceleration: float = 0.25
var current_hook: Area2D = null
var current_zips: Array[Vector2] = []
var invulnerable: bool = false
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var fsm: StateMachine = $StateMachine
@onready var detection_area: Area2D = $detection_area
@onready var attack_ray: RayCast2D =  $RayCast2D
@onready var attack_cooldown_timer: Timer = $attack_cooldown_timer
@onready var invulnerability_timer: Timer = $invulnerability_timer
@onready var no_gravity_timer: Timer = $no_gravity_timer
@onready var death_motion_stop_timer: Timer = $death_motion_stop_timer
@onready var collider: CollisionShape2D = $CollisionShape2D
@onready var ui: Dictionary = {
	"sugar": $CanvasLayer/bottom_left/sugar_level,
	"health": null,
	"gifts": $CanvasLayer/top_left/gifts,
	"time": $CanvasLayer/top_middle/time
}
signal dead

func _ready() -> void:
	ui.sugar.value = sugar_level
	#ui.health.text = str(health)
	ui.gifts.text = str(gifts)

func _process(_delta: float) -> void:
	var step: float = 0.03
	if sugar_level > step:
		sugar_level -= step
		ui.sugar.value = sugar_level


func _physics_process(delta) -> void:
	if fsm.current_state.name == "dead":
		#TODO this block is work in progress
		if no_gravity_timer.is_stopped():
			velocity.y += gravity * delta
		else:
			if death_motion_stop_timer.is_stopped():
				velocity = Vector2.ZERO
			else:
				velocity.y = jump_speed
		
		
	elif Input.is_action_just_pressed("up") && fsm.current_state.name != "falling":
		velocity.y = jump_speed + sugar_level
		if fsm.current_state.name == "hooking":
			current_hook.unhook()
			current_hook = null
			no_gravity_timer.start()

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
				attack_ray.get_collider().damage()


func spill_gifts() -> void:
	var parent: Node2D = get_parent()
	for gift in gifts:
		var gift_to_drop: RigidBody2D = dropable_gift.instantiate()
		gift_to_drop.global_position = global_position + Vector2(0, -32)
		parent.call_deferred("add_child", gift_to_drop)
	gifts = 0
	ui.gifts.text = str(0)


func damage() -> void:
	if !invulnerable:
		if gifts <= 0:
			fsm.current_state.exit("dead")
			no_gravity_timer.start()
			anim.scale.y *= -1
			dead.emit()
		else:
			invulnerability_timer.start()
			invulnerable = true
			spill_gifts()


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


func add_gifts(amt: int) -> void:
	gifts += amt
	ui.gifts.text = str(gifts)


func _on_invulnerability_timer_timeout() -> void:
	invulnerable = false
	modulate = Color(255,255,255,255)


func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation == "attacking":
		anim.play("idle")


func _on_no_gravity_timer_timeout() -> void:
	if fsm.current_state.name == "dead":
		#BUG dosn't look great
		death_motion_stop_timer.start()

func _on_attack_cooldown_timer_timeout() -> void:
	#NOTE this block copied over from key press detection
	if attack_ray.get_collider() && attack_ray.get_collider().is_in_group("enemy"):
		attack_ray.get_collider().damage()
	#NOTE the player technically attacks twice, to allow for a hit on less accurate attacks
		
	if fsm.current_state.name == "idle":
		anim.play("idle")
	elif fsm.current_state.name == "running":
		anim.play("running")
	elif fsm.current_state.name == "falling":
		anim.play("falling")

func _on_death_motion_stop_timer_timeout() -> void:
	anim.call_deferred("queue_free")


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


func _on_dead_state_entered() -> void:
	collider.set_deferred("disabled", true)

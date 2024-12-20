extends CharacterBody2D
var health: int = 5
var target: CharacterBody2D
@onready var fsm: StateMachine = $StateMachine
@onready var close_ray: RayCast2D = $swipe_dist
@onready var far_ray: RayCast2D = $charge_dist
signal dead


func _physics_process(delta: float) -> void:
	if fsm.current_state.name == "moving":
		pass
		# go towards target, if target is hooked, then go back and forth in room
		
	elif fsm.current_state.name == "charging":
		pass #charge, if hit player or wall via swipe dist, stop & change state
		
	elif fsm.current_state.name == "dazed" || fsm.current_state.name == "pre_charging" || fsm.current_state.name == "attacking":
		velocity = Vector2.ZERO


func wake_up(trgt: CharacterBody2D) -> void:
	if fsm.current_state.name == "sleeping":
		target = trgt
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

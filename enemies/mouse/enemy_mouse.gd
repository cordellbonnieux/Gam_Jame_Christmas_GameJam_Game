extends CharacterBody2D
# enemy mouse

var health: int = 1
var speed: int = 50
var friction: float = 0.1
var direction: float = 1.0
var gravity: int = 300
var target: CharacterBody2D = null
@onready var ray_forward: RayCast2D = $ray_forward
@onready var ray_down_forward: RayCast2D = $ray_floor_checker
@onready var attack_collider: CollisionShape2D = $hit_area/CollisionShape2D
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var death_timer: Timer = $death_timer
@onready var collider: CollisionShape2D = $CollisionShape2D

func _process(delta: float) -> void:
	if !death_timer.is_stopped():
		modulate.a -= 0.02

func _physics_process(delta):
	if !death_timer.is_stopped() && (death_timer.time_left > death_timer.wait_time/1.25):
		velocity.y -= gravity * delta * 4

	elif !is_on_floor():
		velocity.y += gravity * delta
		
	elif !ray_down_forward.get_collider() || ray_forward.get_collider():
		# change dir
		direction *= -1
		ray_down_forward.target_position.x *= -1
		ray_forward.target_position.x *= -1
		anim_sprite.scale.x *= -1
	
	else:
		velocity.x = lerp(velocity.x, direction * speed, friction)
		
	move_and_slide()


func damage(amount: int) -> void:
	if death_timer.is_stopped():
		health -= amount
		if health <= 0:
			attack_collider.disabled = true
			collider.disabled = true
			death_timer.start()
			anim_sprite.scale.y *= -1


func _on_hit_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.damage(1)


func _on_death_timer_timeout() -> void:
	queue_free()

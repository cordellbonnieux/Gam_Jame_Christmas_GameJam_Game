extends Node2D

@onready var collider_left: CollisionShape2D = $knob_left/CollisionShape2D
@onready var collider_left_back: CollisionShape2D = $knob_left_back/CollisionShape2D
@onready var collider_right: CollisionShape2D = $knob_right/CollisionShape2D
@onready var collider_right_back: CollisionShape2D = $knob_right_back/CollisionShape2D
@onready var collider_center: CollisionShape2D = $mid_frame/CollisionShape2D

func center_on(body: Node2D) -> void:
		if body.is_in_group("player"):
			collider_center.set_deferred("disabled", false)

func center_off(body: Node2D) -> void:
		if body.is_in_group("player"):
			collider_center.set_deferred("disabled", true)

func left_on(body: Node2D) -> void:
		if body.is_in_group("player"):
			collider_left.set_deferred("disabled", false)

func left_off(body: Node2D) -> void:
		if body.is_in_group("player"):
			collider_left.set_deferred("disabled", true)

func right_on(body: Node2D) -> void:
		if body.is_in_group("player"):
			collider_right.set_deferred("disabled", false)

func right_off(body: Node2D) -> void:
		if body.is_in_group("player"):
			collider_right.set_deferred("disabled", true)

func left_back_on(body: Node2D) -> void:
		if body.is_in_group("player"):
			collider_left_back.set_deferred("disabled", false)

func left_back_off(body: Node2D) -> void:
		if body.is_in_group("player"):
			collider_left_back.set_deferred("disabled", true)

func right_back_on(body: Node2D) -> void:
		if body.is_in_group("player"):
			collider_right_back.set_deferred("disabled", false)

func right_back_off(body: Node2D) -> void:
		if body.is_in_group("player"):
			collider_right_back.set_deferred("disabled", true)

extends Area2D
@export var show_helper: bool = false
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var ui_anim: AnimatedSprite2D = $AnimatedSprite2D2

# TODO make the wreath fall to the floor if hooked too long!
func _ready() -> void:
	ui_anim.play("default")
	if show_helper:
		ui_anim.visible = true
	else:
		ui_anim.visible = false

func hook() -> void:
	anim.play("hook_on")
	if show_helper:
		ui_anim.visible = false

func unhook() -> void:
	anim.play("hook_off")
	#ui_anim.visible = true #dont understand why this wont work here?

func _on_animated_sprite_2d_animation_finished() -> void:
	anim.play("idle")


func _on_body_exited(_body: Node2D) -> void:
	if show_helper:
		ui_anim.visible = true

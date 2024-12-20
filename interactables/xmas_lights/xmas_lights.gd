extends Node2D

@onready var zip: Area2D = $zip_post
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	anim.play()
	for child in get_children():
		if child != zip && child != anim:
			zip.destination = child.zip

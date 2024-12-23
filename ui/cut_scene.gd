extends CanvasLayer

var frame: int = 0
var frames: Array[VBoxContainer] = []

func _ready() -> void:
	for child in get_children():
		frames.append(child)
		if child != frames[0]:
			if child.visible:
				child.visible = false
		elif !frames[0].visible:
			frames[0].visible = true

func next_frame() -> bool:
	frames[frame].visible = false
	if frame < frames.size():
		frame += 1
		
	if frame == frames.size():
		frames[0].visible = true
		return false
	else:
		frames[frame].visible = true
		return true

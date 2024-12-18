extends Area2D

@export var destination: Area2D

# returns the next's position
func get_destination_global_coords() -> Array[Vector2]:
	if destination:
		var arr: Array[Vector2] = [destination.global_position]
		arr.append_array(destination.get_destination_global_coords())
		return arr
	else:
		return []

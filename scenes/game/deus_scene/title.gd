extends Label

func _process(delta):
	rotation_degrees += 30 * delta
	rotation_degrees = fmod(rotation_degrees, 360)
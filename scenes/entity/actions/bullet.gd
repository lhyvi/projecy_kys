extends Node2D

var speed = 65 * 4 
var target = "nonplayer"
var callback: Callable
var tween: Tween
var damage = 1

@export var random_range: float = -8


func shoot(pos: Vector2, new_callback: Callable = func():pass) -> void:
	var target_pos = pos + Vector2(randf_range(-random_range, random_range), randf_range(-random_range, random_range))
	callback = new_callback
	tween = get_tree().create_tween().bind_node(self) 
	tween.tween_property(self, "global_position", target_pos, global_position.distance_to(target_pos) / speed)
	tween.tween_callback(func(): 
		callback.call()
		tween.kill()
		self.queue_free()
		)
	tween.play()


func _on_area_2d_area_entered(area):
	var object = area.get_parent()
	if object.is_in_group(target):
		object = object as Character
		object._on_hit(damage)
		if tween.is_running():
			tween.stop()
			tween.kill()
			callback.call()
			self.queue_free()


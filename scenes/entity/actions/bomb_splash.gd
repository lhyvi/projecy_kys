extends Entity
var damage = 3
var far_damage = 1
var tween: Tween

@export var splash_size: float = 1.5
@export var splash_speed: float = 0.5
@onready var audio_player = $AudioStreamPlayer

var splash_sound = preload("res://assets/sounds/BombExplode.wav")

func _ready():
	super()
	audio_player.stream = splash_sound

func splash(_cell: Cell) -> void:
	tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "scale", Vector2(splash_size, splash_size), splash_speed)
	tween.tween_callback(func(): 
		tween.kill()
		resolve.emit()
		self.queue_free()
		)
	tween.play()
	audio_player.play()

func _on_area_2d_area_entered(area):
	var object = area.get_parent()
	if object.is_in_group(target):
		var dmg = damage if global_position.distance_to(object.global_position) <= 64 else far_damage
		if "_on_hit" in object:
			object._on_hit(dmg)
			print(object, dmg)
		# if tween.is_running():
		# 	tween.stop()
		# 	tween.kill()
		# 	callback.call()
		# 	self.queue_free()

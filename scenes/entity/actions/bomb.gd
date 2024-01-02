@tool
class_name Bomb extends Entity

var speed = 65*3;
@export var bomb_splash_scene: PackedScene
@export var explode_speed: float = 0.25
@export var random_range: float = -16:
	set(value):
		random_range = value
		if Engine.is_editor_hint():
			queue_redraw()

func _init():
	add_to_group("nonplayer")

func _draw():
	if Engine.is_editor_hint():
		draw_circle(global_position, random_range, Color.LIGHT_BLUE) ## Draws random_range fr fr

func throw(entity: Entity, throw_cell: Cell) -> void:
	var throw_pos = throw_cell.global_position + Vector2(randf_range(-random_range, random_range), randf_range(-random_range, random_range))
	var tween = entity.get_tree().create_tween().bind_node(entity) 
	tween.tween_property(entity, "global_position", throw_pos, global_position.distance_to(throw_pos) / speed)
	tween.tween_callback(func(): 
		tween.kill()
		resolve.emit()
		set_resolve(explode_action, throw_cell)
		)
	tween.play()

func explode(entity: Entity, _cell: Cell) -> void:
	var tween = entity.get_tree().create_tween().bind_node(entity).set_trans(Tween.TRANS_BACK)
	tween.tween_property(entity, "scale", scale*2, explode_speed)
	tween.tween_callback(func(): 
		var bomb_splash = bomb_splash_scene.instantiate()
		bomb_splash.set_pos(_cell.pos)
		bomb_splash.global_position = global_position
		bomb_splash.target = target
		entity.get_parent().add_child(bomb_splash)
		bomb_splash.splash(_cell)
		tween.kill()
		entity.queue_free()
		)
	tween.play()

var explode_action = Action.action_from("Explode",
	explode,
	Action.basic_range(),
	Action.ActionType.OFFENSE,
	0,
	Action.basic_area(1, false)
)

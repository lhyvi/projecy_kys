extends Node

var _move_sound = preload("res://assets/sounds/Move.wav")
var _ready_sound = preload("res://assets/sounds/Ready.wav")
var _throw_sound = preload("res://assets/sounds/BombThrow.wav")
var _shoot_sound = preload("res://assets/sounds/Shoot.wav")
var _snipe_sound = preload("res://assets/sounds/Snipe.wav")

var _bullet_scene: PackedScene = preload("res://scenes/entity/actions/bullet.tscn")
var _bomb_scene: PackedScene = preload("res://scenes/entity/actions/bomb.tscn")

func move(entity: Entity,cell: Cell) -> void:
	entity.pos = cell.pos
	var tween = entity.get_tree().create_tween().bind_node(entity).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(entity, "global_position", cell.global_position, 1)
	tween.tween_callback(func(): 
		entity.resolve.emit()
		tween.kill()
		)
	tween.play()
	entity.action_audio_play(_move_sound)

var move_action: Action = Action.action_from("Move",
 move,
 Action.basic_range(1, true),
 Action.ActionType.MOVEMENT,
 0,
 Action.basic_area(0, false)
 )

func energy_recharge(entity: Entity, _cell: Cell) -> void:
	entity.energy += 2
	var tween = entity.get_tree().create_tween().bind_node(entity) 
	var tween2 = entity.get_tree().create_tween().bind_node(entity) 
	tween.tween_property(entity, "rotation_degrees", 180, 0.33)
	tween2.tween_property(entity, "rotation_degrees", 0, 0.33)
	entity.action_audio_play(_ready_sound)
	tween.tween_callback(func(): 
		tween.kill()
		tween2.play()
	)
	tween2.tween_callback(func(): 
		tween2.kill()
		entity.resolve.emit()
	)
	tween.play()
var energy_recharge_action: Action = Action.action_from("Recharge",
 energy_recharge,
 Action.basic_range(0, false),
 Action.ActionType.UTILITY,
 0,
 Action.basic_area(0, false)
 )

func shoot(entity: Entity, cell: Cell) -> void:
	await entity.get_tree().create_timer(0.25).timeout
	var bullet = _bullet_scene.instantiate()
	entity.get_parent().add_child(bullet)
	bullet.global_position = entity.global_position
	bullet.target = entity.target
	bullet.shoot(cell.global_position, func():
		entity.resolve.emit()
	)
	entity.action_audio_play(_shoot_sound)

var shoot_action: Action = Action.action_from("Shoot", # Name
	shoot, # Action Callable
	Action.basic_range(2,true), # Action Range
	Action.ActionType.OFFENSE, # Action Type
	1, # Action Cost
	Action.basic_area(0, false)
	)

func snipe(entity: Entity, cell: Cell) -> void:
	entity.state = Entity.State.Action
	entity.set_resolve(snipe_finish_action, cell)
	var tween = entity.get_tree().create_tween().bind_node(entity) 
	var tween2 = entity.get_tree().create_tween().bind_node(entity) 
	tween.tween_property(entity, "rotation_degrees", 180, 0.33)
	tween2.tween_property(entity, "rotation_degrees", 0, 0.33)
	tween.tween_callback(func(): 
		entity.action_audio_play(_ready_sound)
		tween.kill()
		tween2.play()
	)
	tween2.tween_callback(func(): 
		tween2.kill()
		entity.resolve.emit()
	)
	tween.play()
func _snipe(entity: Entity, cell: Cell) -> void:
	await entity.get_tree().create_timer(0.25).timeout
	var bullet = _bullet_scene.instantiate()
	entity.get_parent().add_child(bullet)
	bullet.global_position = entity.global_position
	bullet.target = entity.target
	bullet.speed *= 4
	bullet.damage = 3

	entity.action_audio_play(_snipe_sound)
	bullet.shoot(cell.global_position, func():
		entity.resolve.emit()
	)
var snipe_action: Action = Action.action_from("Snipe",
	snipe,
	Action.snipe_range(),
	Action.ActionType.OFFENSE,
	5,
	Action.snipe_area()
	)
var snipe_finish_action: Action = Action.action_from("Snipe",
	_snipe,
	Action.snipe_range(),
	Action.ActionType.OFFENSE,
	-1,
	Action.snipe_area()
	)

func bomb(entity: Entity, cell: Cell) -> void:
	var bomb_instance = _bomb_scene.instantiate()
	bomb_instance.set_pos(cell.pos)
	entity.get_parent().add_child(bomb_instance)
	bomb_instance.global_position = entity.global_position
	bomb_instance.target = entity.target
	bomb_instance.throw(bomb_instance, cell)
	entity.action_audio_play(_throw_sound)
	pass

var bomb_action: Action = Action.action_from("Bomb",
	bomb,
	Action.bomb_range(),
	Action.ActionType.OFFENSE,
	5,
	Action.basic_area(1, false)
)

var all_actions: Array = [
	move_action,
	energy_recharge_action,
	shoot_action,
	snipe_action,
	bomb_action,
]

func get_all_actions() -> Array:
	return all_actions


class_name Entity extends Node2D

signal resolve()

enum State {
	Idle,
	Action
}

@export var pos: Vector2 = Vector2(0, 1):
	set(value):
		prev_pos = pos
		value = value as Vector2
		value = value.clamp(Vector2(0,0), Vector2(ResourceManager.columns, ResourceManager.rows))
		pos = value

@onready var prev_pos: Vector2 = pos

var state = State.Idle
var resolve_action: Action
var resolve_cell: Cell
var target: String = "nonplayer"

func _ready():
	connect("resolve", ResourceManager.game_manager._on_action_resolve)
	ResourceManager.game_manager.connect("start_menu", _on_start_menu)
	ResourceManager.game_manager.connect("start_resolve", _on_start_resolve)
	ResourceManager.game_manager.connect("start_preresolve", _on_preresolve)
	pass

func get_pos() -> Vector2:
	return pos

func set_pos(new_pos: Vector2) -> void:
	pos = new_pos

func set_resolve(action: Action, cell: Cell) -> void:
	resolve_action = action;
	resolve_cell = cell;

func do_action(action: Action, cell: Cell) -> void:
	action.callable.call(self, cell)

func _on_start_menu():
	pass

func _on_preresolve():
	pass

func _on_start_resolve():
	var gm = ResourceManager.game_manager as GameManager
	if gm:
		gm._on_action_begin()
	if resolve_action:
		_start_resolve_call()
		resolve_action.callable.call(self, resolve_cell)

func _start_resolve_call():
	# if state == State.Action:
	# 	state = State.Idle
	# else:
	# 	energy -= resolve_action.cost
	pass

class_name Arena extends Node2D

@export var cell_scene: PackedScene
@export var cell_size: int = 64
@export var cell_offset: int = 2

@onready var columns = ResourceManager.columns
@onready var rows = ResourceManager.rows
@onready var cell_rsize: int = cell_size + cell_offset
@onready var arena_size: Vector2 = Vector2(cell_rsize * columns - cell_offset, cell_rsize * rows - cell_offset)

@warning_ignore("integer_division")
@onready var arena_offset: Vector2 = arena_size/2 - Vector2(cell_rsize/2 - (cell_offset/2),cell_rsize/2 -(cell_offset/2))

var cell_array: Array
var global_offset = 32

signal cell_pressed(cell: Cell)
func _init():
	ResourceManager.arena = self

func _ready():
	$placeholder.visible = false
	init_cell_array()
	ResourceManager.game_manager.connect("game_state_changed", _on_game_state_changed)

func init_cell_array() -> void:
	cell_array.resize(columns * rows)
	for row in rows:
		for col in columns:
			var cell: Cell = cell_scene.instantiate() as Cell
			add_child(cell)
			cell.set_owner(get_tree().edited_scene_root)
			var cell_pos = Vector2(col, row)
			cell.pos = cell_pos
			var temp_pos = (Vector2(1,1) * col * cell_rsize) + (Vector2(1, -1) * row * cell_rsize)
			var old_pos = Vector2(col * cell_rsize, row * cell_rsize)
			cell.global_position = global_position + old_pos - arena_offset
			cell_array[get_cell_index(cell_pos)] = cell
			cell.connect("pressed", _on_cell_pressed)


func set_disabled_cells(disabled: bool) -> void:
	for cell in cell_array:
		cell = cell as Cell
		cell.disabled = disabled
		pass
	pass

@warning_ignore("shadowed_global_identifier")
func set_selectable(pos: Vector2, range_function: Callable) -> void:
	var cells = get_selectable(pos, range_function)
	for cell in cells:
		cell = cell as Cell
		cell.set_selectable(true)

func get_selectable(character_pos: Vector2, range_function: Callable) -> Array:
	var cells = cell_array.filter(func(cell):
		return range_function.call(character_pos, cell.pos)
		)
	return cells
func get_selectable_area(selected_pos: Vector2,  character_pos: Vector2, range_function: Callable) -> Array:
	var cells = cell_array.filter(func(cell):
		return range_function.call(selected_pos, character_pos, cell.pos)
		)
	return cells

func get_cell(cell_pos: Vector2) -> Cell:
	return cell_array[get_cell_index(cell_pos)]

func get_cell_array() -> Array:
	return cell_array.duplicate()

func index_to_vec(index: int) -> Vector2:
	@warning_ignore("integer_division")
	return Vector2(index % columns, index / columns)

func get_cell_index(pos: Vector2) -> int:
	return pos.y * columns + pos.x

func get_cell_pos(pos: Vector2) -> Vector2:
	return cell_array[get_cell_index(pos)].global_position

func clear_mark() -> void:
	for cell in cell_array:
		cell = cell as Cell
		cell.clear()

func _on_game_state_changed(game_state: GameManager.GameState):
	set_disabled_cells(game_state != GameManager.GameState.Action)

func _on_cell_pressed(cell: Cell) -> void:
	cell_pressed.emit(cell)

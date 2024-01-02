class_name Action extends Resource

enum ActionType {
	MOVEMENT,
	OFFENSE,
	UTILITY
}

var text: String ## Name
var cost: int
var callable: Callable ## Needs to at some point do resolve.emit()
var range_function: Callable ## Determines the range you can do an action
var action_type: ActionType
var area_function: Callable ## Determines the area the actions effect happens

static func action_from(
	ntext: String,
	ncall: Callable, 
	nrange_function: Callable = basic_range(), 
	naction_type: ActionType = ActionType.OFFENSE, 
	ncost: int = 0,
	narea_function: Callable = basic_range(0, false), 
	) -> Action:

	var action = Action.new()
	action.text = ntext
	action.callable = ncall
	action.cost = ncost
	action.range_function = nrange_function
	action.action_type = naction_type
	action.area_function = narea_function
	return action

static func manhattan_distance_vector(a: Vector2, b: Vector2) -> Vector2:
	var c = abs(a - b)
	return c

static func manhattan_distance(a: Vector2, b: Vector2) -> float:
	var c = abs(a - b)
	return c.x + c.y

static func basic_range(valid_range: float = 1, exclusive: bool= true) -> Callable:
	var lambda = func(character_pos: Vector2, cell_pos: Vector2):
		var within_range = character_pos.distance_to(cell_pos) <= valid_range
		var is_exclusive = (character_pos != cell_pos) if exclusive else true
		return  within_range and is_exclusive
	return lambda

static func basic_area(valid_range: float = 1, exclusive: bool = false) -> Callable:
	var lambda = func(selected_pos: Vector2, _character_pos: Vector2, cell_pos: Vector2):
		return selected_pos.distance_to(cell_pos) <= valid_range and ((selected_pos != cell_pos) if exclusive else true)
	return lambda

# static func same_row(exclusive: bool= true) -> Callable:
# 	var lambda = func(character_pos: Vector2, cell_pos: Vector2):
# 		return character_pos.y == cell_pos.y and ((character_pos != cell_pos) if exclusive else true)
# 	return lambda

static func snipe_range(exclusive: bool = true) -> Callable:
	var lambda = func(character_pos: Vector2, cell_pos: Vector2):
		var same_y = cell_pos.y == character_pos.y
		var is_edge = cell_pos.x == 0 or cell_pos.x == 6
		var is_exclusive = (character_pos != cell_pos) if exclusive else true
		return same_y and is_edge and is_exclusive
	return lambda

static func snipe_area() -> Callable:
	var lambda = func(selected_pos: Vector2, character_pos: Vector2, cell_pos: Vector2,):
		var facing_right = character_pos.x < selected_pos.x
		var char_faces_cell = character_pos.x < cell_pos.x if facing_right else cell_pos.x < character_pos.x
		# print(cell_pos, "fright, ", facing_right, char_faces_cell)

		return selected_pos.y == cell_pos.y and char_faces_cell
	return lambda

static func bomb_range() -> Callable:
	var lambda = func(bomb_pos: Vector2, cell_pos: Vector2):
		var dist = abs(manhattan_distance_vector(bomb_pos, cell_pos))
		return dist.x == 2 and dist.y == 1
		## ../
		## o..
		## ../
	return lambda

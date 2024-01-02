class_name Enemy extends Node2D

@onready var arena = ResourceManager.arena
@onready var gm = ResourceManager.game_manager
var character: Character

func set_character(new_character: Character):
	character = new_character
	var character_parent = new_character.get_parent()
	if character_parent:
		character_parent.remove_child(character)
	add_child(new_character)
	character.target = "player"
	character.add_to_group("nonplayer")
	return

static func enemy_from(enemy_character: Character) -> Enemy:
	var enemy = Enemy.new()
	enemy.set_character(enemy_character)
	enemy.character = enemy_character
	return enemy

func _ready():
	# gm.connect("start_preresolve", _on_preresolve)
	gm.connect("start_menu", _on_start_menu)
	character.connect("hp_changed", gm.update_enemy_hp)
	character.energy = character.energy
	character.hp = character.hp

func _on_start_menu():
	# print("Enemy Energy, ", character.energy)
	if character.state == Entity.State.Action:
		return

	var all_offenses = character.get_offensive_actions()
	var available_offenses = Array()
	for action in all_offenses:
		if action.cost > character.energy:
			continue
		available_offenses.append(action)

	var hit_offenses = Array()
	for action in available_offenses:
		var action_hits = action_hits_player(action)
		if action_hits:
			hit_offenses.append(action)
	
	# print(available_offenses.map(func(action): return action.text))
	# print(hit_offenses.map(func(action): return action.text))

	var current_cell = arena.get_cell(character.pos)
	var danger_cells = get_cells_in_danger()
	var in_danger = current_cell in danger_cells

	var choices = Array()

	var move_farther_choice = func(): move_farther(danger_cells)
	var move_closer_choice = func(): move_closer(danger_cells)
	var energy_recharge_action = Actions.energy_recharge_action

	if in_danger:
		choices.append(move_farther_choice)
	else:
		if not hit_offenses.is_empty():
			var offense_choice = func(): set_resolve_from(hit_offenses)
			choices.append(offense_choice)
			choices.append(offense_choice)
		if available_offenses.is_empty():
			choices.append(func(): character.set_resolve(energy_recharge_action, current_cell))
		else:
			choices.append([move_closer_choice, move_farther_choice].pick_random())
			if available_offenses.size() != all_offenses.size():
				choices.append(func(): character.set_resolve(energy_recharge_action, current_cell))

	choices.pick_random().call()

func move_closer(danger_cells: Array = Array()):
	var move_action = Actions.move_action
	var move_cells = arena.get_selectable(character.pos, move_action.range_function)
	var filtered = move_cells.filter(func(cell): return cell not in danger_cells)
	if filtered.is_empty():
		filtered = move_cells
	character.set_resolve(move_action, get_closest_cell_to_player(filtered))

func move_farther(danger_cells: Array = Array()):
	var move_action = Actions.move_action
	var move_cells = arena.get_selectable(character.pos, move_action.range_function)
	var filtered = move_cells.filter(func(cell): return cell not in danger_cells)
	if filtered.is_empty():
		filtered = move_cells
	character.set_resolve(move_action, get_farthest_cell_to_player(filtered))


func set_resolve_from(actions: Array):
		var action = actions.pick_random()
		var cell = get_closest_cell_to_player(arena.get_selectable(character.pos, action.range_function))
		character.set_resolve(action, cell)
		# print("selected action ", action.text)
		# print("selected cell ", cell.pos)

func get_closest_cell_from_action(action: Action) -> Cell:
	return get_closest_cell_to_player(arena.get_selectable(character.pos, action.range_function))

func get_cells_in_danger() -> Array:
	var dangers = Array()
	var player = ResourceManager.player
	if player.resolve_action and player.resolve_action.action_type == Action.ActionType.OFFENSE and player.state == Entity.State.Action:
		var action = player.resolve_action
		var range_cells = arena.get_selectable(player.pos, action.range_function)
		for rcell in range_cells:
			var area_cells = arena.get_selectable_area(rcell.pos, player.pos, action.area_function)
			dangers.append_array(area_cells)
	
	var non_players = get_tree().get_nodes_in_group("nonplayer")
	for np in non_players:
		if np.target == character.target:
			continue
		if not np.resolve_action:
			continue
		var cells = arena.get_selectable_area(np.pos, np.pos, np.resolve_action.area_function)
		dangers.append_array(cells)
		
	# print(dangers.map(func(cell): return cell.pos))

	return dangers

func get_closest_cell_to_player(cells: Array) -> Cell:
	var ppos = ResourceManager.player.pos

	var nearest_cell = cells.reduce(
		func(min_cell, cell): 
			return cell if Enemy.manhattan_distance(ppos, cell.pos) < Enemy.manhattan_distance(ppos, min_cell.pos) else min_cell)
	var nearest_dist = Enemy.manhattan_distance(nearest_cell.pos, ppos)

	var nearest_cells = cells.filter(
		func(cell): 
			return true if Enemy.manhattan_distance(ppos,cell.pos) == nearest_dist else false)
	var chosen_cell = nearest_cells.pick_random()

	return chosen_cell
func get_farthest_cell_to_player(cells: Array) -> Cell:
	var ppos = ResourceManager.player.pos

	var farthest_cell = cells.reduce(
		func(max_cell, cell): 
			return cell if Enemy.manhattan_distance(ppos, cell.pos) > Enemy.manhattan_distance(ppos, max_cell.pos) else max_cell)
	var farthest_dist = Enemy.manhattan_distance(farthest_cell.pos, ppos)

	var farthest_cells = cells.filter(
		func(cell): 
			return true if Enemy.manhattan_distance(ppos,cell.pos) == farthest_dist else false)
	var chosen_cell = farthest_cells.pick_random()

	return chosen_cell

func action_hits_player(action: Action) -> bool:
	var ppos = ResourceManager.player.pos
	var range_cells = arena.get_selectable(character.pos, action.range_function)
	# print(action.text)
	# print(range_cells.map(func(cell): return cell.pos))
	for rcell in range_cells:
		var area_cells = arena.get_selectable_area(rcell.pos, character.pos, action.area_function)
		# print(area_cells.map(func(cell): return cell.pos))
		for acell in area_cells:
			if acell.pos == ppos:
				return true
	return false

static func manhattan_distance(a: Vector2, b: Vector2) -> float:
	var c = abs(a - b)
	return c.x + c.y



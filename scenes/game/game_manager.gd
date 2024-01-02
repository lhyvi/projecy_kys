class_name GameManager extends Node2D

signal start_menu()
signal start_preresolve()
signal start_resolve()
signal game_state_changed(game_state: GameState)


@onready var arena  = $"Arena" as Arena
@onready var actions = $"Actions" as ActionsUI
@onready var energy_label = $"EnergyLabel" as RichTextLabel
@onready var player_hp_label = $"PHLabel" as RichTextLabel
@onready var enemy_hp_label = $"EHLabel" as RichTextLabel
@onready var enemy_action_label = $"EnemyActionLabel" as RichTextLabel


@onready var columns = ResourceManager.columns
@onready var rows = ResourceManager.rows

var player: Player = Player.player_from(preload("res://scenes/entity/character.tscn").instantiate())
var enemy: Enemy = Enemy.enemy_from(preload("res://scenes/entity/character.tscn").instantiate())

var resolve_count: int = 0
var selected_action: Action
var _player_lost = false;


enum GameState {
	Menu,
	Wait,
	Action,
	Resolve,
	End
}

var game_state = GameState.Menu:
	set(value):
		print("Game State, ", GameState.keys()[value])
		game_state = value
		game_state_changed.emit(game_state)
		if value == GameState.Menu:
			setup_menu_state()


func _init():
	ResourceManager.game_manager = self

func _ready():
	add_child(player)
	add_child(enemy)

	arena.connect("cell_pressed", _cell_pressed)
	actions.back.connect("pressed", _cancel_action)
	actions.wait.connect("pressed", begin_resolve)

	place(player.character, Vector2(0,1))
	place(enemy.character, Vector2(6,1))
	begin_menu()
	setup_ui()

func update_energy_label(value):
	if not energy_label:
		return
	energy_label.text = "[center]Energy: %d" %  value

func update_player_hp(value):
	if not player_hp_label:
		return
	player_hp_label.text = "[center]" + ("♥".repeat(value) if value > 0 else "💀")

func update_enemy_hp(value):
	if not enemy_hp_label:
		return
	enemy_hp_label.text = "[center]" + ("♥".repeat(value) if value > 0 else "💀")

func update_enemy_action_labels():
	var action = enemy.character.resolve_action
	var cell = enemy.character.resolve_cell
	enemy_action_label.text = "[center]" + action.text
	print(enemy.character.pos, action.text, cell.pos)
	var area_cells = arena.get_selectable_area(cell.pos, enemy.character.pos, action.area_function)
	for acell in area_cells:
		acell.danger = true

func setup_menu_state() -> void:
	if player.character.state == player.character.State.Action:
		game_state = GameState.Wait
	else:
		setup_ui()

func setup_ui() -> void:
	actions.clear_buttons()
	for act in player.character.available_actions:
		var button = actions.add_button(act.text, func(): receive_action(act), act.cost)
		if act.cost > player.character.energy:
			button.button.disabled = true
	print("Enemy Action : ", enemy.character.resolve_action.text)
	update_enemy_action_labels()

func receive_action(action: Action) -> void:
	game_state = GameState.Action
	selected_action = action
	arena.set_selectable(player.character.pos, action.range_function)

func begin_menu() -> void:
	arena.clear_mark()
	start_menu.emit()
	game_state = GameState.Menu
	pass

func begin_resolve() -> void:
	game_state = GameState.Resolve
	start_preresolve.emit()

	_on_action_begin()
	get_tree().create_timer(0.25).connect("timeout", _on_action_resolve) # Guarantees that all actions at start before resolve_count goes to 0
	# Without this, in the case that an action resolves immediately, the resolve_count might go to 0 at an unintended time
	# which ends the resolve phase prematurely

	start_resolve.emit()


func finish_resolve() -> void:
	if game_state == GameState.Resolve or game_state == GameState.Wait:
		begin_menu()
	elif game_state == GameState.End:
		game_over()
	else:
		printerr("Got resolve when not in Resolve or End state")

func game_over() -> void:
	await get_tree().create_timer(1).timeout
	ResourceManager.god_text = "Player Lost" if _player_lost else "Player Won"
	ResourceManager.goto_scene(ResourceManager.main_menu_scene)

# only used once at _ready
func place(p_char: Character, cell_pos: Vector2) -> void:
	p_char.global_position = arena.get_cell_pos(cell_pos)
	p_char.pos = cell_pos

func check_pos_conflict() -> bool:
	if enemy.character.pos == player.character.pos:
		_on_action_begin()
		player.character.do_action(Actions.move_action,(arena.get_cell(
			(player.character.pos + Vector2.LEFT) if player.character.pos.x > 0 else player.character.pos
			)))

		_on_action_begin()
		enemy.character.do_action(Actions.move_action,(arena.get_cell(
			(enemy.character.pos + Vector2.RIGHT) if enemy.character.pos.x < columns - 1 else enemy.character.pos
			)))
		return true
	return false


func _on_death(character: Character) -> void:
	game_state = GameState.End
	if character.is_in_group("player"):
		_player_lost = true;
		print("Player Lost")
	else:
		print("Enemy Died")

func _cell_pressed(cell: Cell) -> void:
	if cell.selectable:
		arena.clear_mark()
		player.character.set_resolve(selected_action, cell)
		begin_resolve()


func _on_action_begin() -> void:
	resolve_count += 1

## Character callback once Action is finished
func _on_action_resolve() -> void:
	resolve_count -= 1
	if resolve_count > 0:
		return
	if check_pos_conflict():
		return
	finish_resolve()

func _cancel_action() -> void:
	game_state = GameState.Menu
	arena.clear_mark()
	update_enemy_action_labels()
	pass

class_name ActionsUI extends Control

@export var button_scene: PackedScene
@onready var container = $OptionContainer
@onready var back = $Back
@onready var wait = $Wait
var buttons: Array = Array()

func _ready():
	ResourceManager.game_manager.connect("game_state_changed", _on_game_state_changed)
	pass


func add_button(text: String, callable: Callable, cost):
	var button = button_scene.instantiate()
	container.add_child(button)
	button.label.text = "[center][b]%d[/b]" % cost
	button.button.text = text
	button.button.connect("pressed", callable)
	buttons.append(button)
	return button

func clear_buttons() -> void:
	for button in container.get_children():
		button.queue_free()


func _on_game_state_changed(game_state: GameManager.GameState):
	container.set_visible(game_state == GameManager.GameState.Menu)
	back.set_visible(game_state == GameManager.GameState.Action)
	wait.set_visible(game_state == GameManager.GameState.Wait)

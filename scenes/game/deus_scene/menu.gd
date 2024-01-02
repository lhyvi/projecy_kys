extends Node2D

@export_file("*.tscn") var main_scene
@onready var title = $Label
@onready var play_button = $PlayButton
@onready var exit_button = $ExitButton

func _ready():
	if ResourceManager.god_text:
		title.text = ResourceManager.god_text
	if OS.has_feature("web"):
		exit_button.visible = false

func _on_exit_button_pressed():
	ResourceManager.quit()

func _on_play_button_pressed():
	ResourceManager.goto_scene(main_scene)

func _on_palette_button_pressed():
	ResourceManager.current_gradient += 1
	print(ResourceManager.current_gradient)
	pass # Replace with function body.

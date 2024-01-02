extends Node
var columns = 7
var rows = 3

@export_file("*.tscn") var main_menu_scene

var loading_scene = preload("res://scenes/UI/loading.tscn").instantiate()
@export var options_scene: PackedScene
@export var popup_scene: PackedScene
@onready var button_audio: AudioStreamPlayer = $ButtonAudio

@export var gradients: Array[Gradient]
@onready var current_gradient = 0:
	set(value):
		current_gradient = posmod(value, gradients.size())
		set_shader()
var shader

func set_shader():
	if shader:
		shader.set_shader_gradient(gradients[current_gradient])

func get_gradient():
	return gradients[current_gradient]

var game_manager: GameManager
var player: Character
var arena: Arena
var current_scene = null

var god_text = null

func _ready():
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)
	print("Current Scene", current_scene)


func goto_scene(path):
	ResourceLoader.load_threaded_request(path)
	call_deferred("_deferred_goto_scene", path)


func open_options():
	current_scene.add_child(options_scene.instantiate())


func show_message(message):
	var popup = popup_scene.instantiate() as PopUp
	current_scene.add_child(popup)
	popup.set_text(message)

func confirm_message(message):
	var popup = popup_scene.instantiate() as PopUp
	current_scene.add_child(popup)
	popup.set_text(message)
	popup.set_confirmation()
	return await popup.confirm


func quit():
	get_tree().quit()

func play_press():
	button_audio.play()


func _deferred_goto_scene(path):
	current_scene.free()
	loading_scene.next_scene = path
	loading_scene.finished = false
	get_tree().root.add_child(loading_scene)
	print("Finished Loading Shit")

func _loading_finished(path):
	if path == "":
		return
	var next_scene = ResourceLoader.load_threaded_get(path)
	print("next scene, ", next_scene)
	print("path, ", path)
	current_scene = next_scene.instantiate()
	get_tree().root.remove_child(loading_scene)
	get_tree().root.add_child(current_scene)
	get_tree().current_scene = current_scene

@tool
class_name Loading extends Node2D

@export var dot_max = 3
@export var txt = "loading"
@onready var timer = $Label/Timer as Timer
@onready var label = $Label

var next_scene: String = ""
var dot_count = 0:
	set(value):
		dot_count = posmod(value,dot_max + 1)
var finished := false

func _ready():
	timer.start()


func _process(_delta):
	if finished:
		return
	if not next_scene:
		return
	if ResourceLoader.load_threaded_get_status(next_scene) == ResourceLoader.THREAD_LOAD_LOADED:
		await get_tree().create_timer(1).timeout
		if not finished:
			ResourceManager._loading_finished(next_scene)
			finished = true


func _on_timer_timeout():
	dot_count += 1
	label.text = txt + (".".repeat(dot_count))

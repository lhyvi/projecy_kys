class_name Character extends Entity

signal energy_changed(value)
signal hp_changed(value)

@export var start_hp = 3
@export var start_energy = 10

@onready var hit_audio_player: AudioStreamPlayer = $HitPlayer
@onready var action_audio_player: AudioStreamPlayer = $ActionPlayer


var hp =  3:
	set(value):
		hp = value
		check_dead(hp)
		hp_changed.emit(hp)
var energy = 0:
	set(value):
		energy = value
		energy_changed.emit(energy)

var available_actions: Array = Actions.get_all_actions()

var _hurt_sound = preload("res://assets/sounds/Hurt.wav")

func _ready():
	super._ready()
	hp = start_hp
	energy = start_energy


func damage(damage_amount: int = 1):
	hp -= damage_amount

func check_dead(hp):
	if hp == null:
		return
	if hp <= 0: 
		_on_death()


func action_audio_play(audio):
	action_audio_player.stream = audio
	action_audio_player.play()

func play_die_animation() -> void:
	ResourceManager.game_manager._on_action_begin()
	var tween = get_tree().create_tween().bind_node(self) 
	tween.tween_property(self, "rotation_degrees", 360, 0.75)
	tween.tween_callback(func(): 
		set_visible(false)
		resolve.emit()
		tween.kill()
		)
	tween.play()


func get_movement_actions():
	return available_actions.filter(
		func(action): 
			return action.action_type == Action.ActionType.MOVEMENT
	)

func get_offensive_actions():
	return available_actions.filter(
		func(action): 
			return action.action_type == Action.ActionType.OFFENSE
	)

func get_utilitiy_actions():
	return available_actions.filter(
		func(action): 
			return action.action_type == Action.ActionType.UTILITY
	)

func get_available_actions() -> Array:
	return available_actions


func _start_resolve_call():
	if state == State.Action:
		state = State.Idle
	else:
		energy -= resolve_action.cost

func _on_hit(damage_amount = 1):
	hit_audio_player.stream = _hurt_sound
	hit_audio_player.play()
	self.damage(damage_amount)

func _on_death():
	print(self, "died")
	ResourceManager.game_manager._on_death(self)
	play_die_animation()

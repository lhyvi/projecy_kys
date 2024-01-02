class_name PopUp extends Control

signal confirm(confirmation: bool)
@onready var label = $Label
@onready var okb = $OkButton
@onready var yb = $YesButton
@onready var nb = $NoButton

func set_text(text):
	label.text = text

func set_confirmation():
	okb.visible = false
	yb.visible = true
	nb.visible = true


func _on_ok_button_pressed():
	ResourceManager.play_press()
	self.queue_free()
	pass # Replace with function body.

func _on_yes_button_pressed():
	ResourceManager.play_press()
	confirm.emit(true)
	self.queue_free()

func _on_no_button_pressed():
	ResourceManager.play_press()
	confirm.emit(false)
	self.queue_free()

extends Control

@onready var back_button = $VBoxContainer/BackButton


func _on_exit_to_title_button_pressed():
	if await ResourceManager.confirm_message("Unsaved Progress Will Be Lost.\nContinue to Exit?"):
		ResourceManager.goto_scene(ResourceManager.main_menu_scene)

func _on_back_button_pressed():
	self.queue_free()

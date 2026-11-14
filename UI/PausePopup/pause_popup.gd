extends Control

func _ready() -> void:
	UIHelper.set_theme_colors(self)
	get_tree().paused = true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("continue") or event.is_action_pressed("ui_cancel"):
		delete()
	else:
		get_viewport().set_input_as_handled()

func _on_continue_btn_pressed() -> void:
	delete()

func _on_give_up_btn_pressed() -> void:
	delete()
	Game.in_game = false
	SceneSwitcher.switch_to_file("res://UI/main_menu.tscn")

func delete():
	get_tree().paused = false
	self.queue_free()

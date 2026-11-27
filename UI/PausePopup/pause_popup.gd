extends GamePopup 

func _ready() -> void:
	UIHelper.set_theme_colors(self)
	get_tree().paused = true
	super()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("continue") or event.is_action_pressed("ui_cancel"):
		close()

func _on_continue_btn_pressed() -> void:
	close()

func _on_settings_btn_pressed() -> void:
	var popup : GamePopup = UI.show_screen(UI.Popups.SETTINGS)
	self.visible = false
	await popup.finished
	self.visible = true

func _on_give_up_btn_pressed() -> void:
	close()
	Game.in_game = false
	SceneSwitcher.switch_to_file("res://UI/main_menu.tscn")

func close():
	get_tree().paused = false
	super.close()
	self.queue_free()

func set_focus():
	%ContinueBtn.grab_focus()

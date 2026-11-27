extends Button

func _input(event: InputEvent) -> void:
	if !self.has_focus(): return
	if event.is_action_pressed("ui_select"):
		self.pressed.emit()

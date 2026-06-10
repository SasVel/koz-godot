extends Button

func _ready() -> void:
	self.add_theme_color_override("font_color", Const.ACTION_COLOR)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("end_turn"):
		tween_end_turn()

func tween_end_turn():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.2)
	tween.tween_property(self, "scale", Vector2.ONE, 0.2)

func _on_pressed() -> void:
	Game.end_turn()
	self.disabled = true
	await Game.on_start_turn
	self.disabled = false

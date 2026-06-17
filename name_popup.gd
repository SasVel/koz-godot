extends Control

signal finished

func _on_line_edit_text_changed(new_text: String) -> void:
	%DoneBtn.disabled = new_text.length() <= 0

func _on_line_edit_text_submitted(new_text: String) -> void:
	Game.player_name = new_text
	finished.emit()

func _on_done_btn_pressed() -> void:
	Game.player_name = %LineEdit.text
	finished.emit()

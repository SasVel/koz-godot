extends Control

func _on_mouse_entered() -> void:
	owner.grab_focus()

func _on_mouse_exited() -> void:
	owner.release_focus()

func _get_drag_data(at_position: Vector2) -> Variant:
	return owner._get_drag_data(at_position)

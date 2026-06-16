extends Control

func _on_mouse_entered() -> void:
	if owner == null: return
	owner.grab_focus()

func _on_mouse_exited() -> void:
	if owner == null: return
	owner.release_focus()

func _get_drag_data(at_position: Vector2) -> Variant:
	return owner._get_drag_data(at_position)

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return owner._can_drop_data(at_position, data)

func _drop_data(at_position: Vector2, data: Variant) -> void:
	owner._drop_data(at_position, data)

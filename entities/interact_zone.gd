extends Control

func _on_mouse_entered() -> void:
	owner.grab_focus()

func _on_mouse_exited() -> void:
	owner.release_focus()

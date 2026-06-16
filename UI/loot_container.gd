extends HBoxContainer

func _on_sort_children() -> void:
	for child in self.get_children():
		child.set_defaults()

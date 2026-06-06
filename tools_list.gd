extends HBoxContainer

func _on_sort_children() -> void:
	for child in self.get_children().filter(func(x): return x is CardObj):
		child.set_defaults()

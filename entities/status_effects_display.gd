extends HBoxContainer


func _on_enemy_status_effects_changed(status_effects: Variant) -> void:
	for child in self.get_children():
		child.queue_free()

	for info in status_effects:
		var action_obj = ObjManager.get_eff_mini_obj(info)
		self.add_child(action_obj)

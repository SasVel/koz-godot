extends HBoxContainer


func on_status_eff_changed(status_effects : Array) -> void:
	var children = self.get_children()
	for child in children:
		if status_effects.any(func(x): return x == child.data):
			continue
		else:
			child.queue_free()

	children = self.get_children()
	for eff_data in status_effects:
		if children.all(func(x): return x.data != eff_data):
			var action_obj = ObjManager.get_eff_mini_obj(eff_data)
			self.add_child(action_obj)

func _on_player_status_effects_changed(status_effects: Variant) -> void:
	on_status_eff_changed(status_effects)

func _on_enemy_status_effects_changed(status_effects: Variant) -> void:
	on_status_eff_changed(status_effects)

extends HBoxContainer


func on_status_eff_changed(status_effects : Array) -> void:
	var children = self.get_children()
	for child in children:
		child.delete()

	for info in status_effects:
		var action_obj = ObjManager.get_eff_mini_obj(info)
		self.add_child(action_obj)

func _on_player_status_effects_changed(status_effects: Variant) -> void:
	on_status_eff_changed(status_effects)

func _on_enemy_status_effects_changed(status_effects: Variant) -> void:
	on_status_eff_changed(status_effects)

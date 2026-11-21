extends HBoxContainer


func _on_enemy_drawn_hand(_cards) -> void:
	pass


func _on_enemy_hand_changed(_cards) -> void:
	pass


# Coroutine so `await %ActionsDisplay.tween_action(action)` resolves quickly.
func tween_action(_card) -> void:
	await get_tree().process_frame

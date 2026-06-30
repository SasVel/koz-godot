extends HBoxContainer

func _on_enemy_hand_changed(cards_hand: Variant) -> void:
	for child in self.get_children():
		child.queue_free()

	for info in cards_hand:
		var action_obj = ObjManager.get_action_mini_obj(info)
		self.add_child(action_obj)

func tween_action(card_data : CardData):
	var children = self.get_children()
	for child in children:
		if child.data == card_data:
			owner.tween_action()
			await child.tween_activate() 
			return

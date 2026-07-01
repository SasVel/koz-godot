extends Control
class_name LootPopup

signal finished

func _ready() -> void:
	UIHelper.set_theme_colors(self)
	self.theme_changed.emit()
	var card_rewards = ObjManager.get_rand_action_objects(3)
	if randi_range(0, 3) == 3:
		if randi_range(0, 1):
			card_rewards.append(ObjManager.get_rand_weapon_obj())
		else:
			card_rewards.append(ObjManager.get_rand_shield_obj())

	for reward in card_rewards:
		%LootContainer.add_child(reward)
		reward.isLoot = true
		reward.focus_card_pos_y = 0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("continue"):
		finished.emit()
		self.queue_free()

func _on_continue_btn_pressed() -> void:
	finished.emit()
	self.queue_free()

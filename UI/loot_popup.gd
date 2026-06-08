extends Control
class_name LootPopup

func _ready() -> void:
	var card_rewards = ObjManager.get_rand_action_objects(3)
	if randi_range(0, 3) == 3:
		if randi_range(0, 1):
			card_rewards.append(ObjManager.get_rand_weapon_obj())
		else:
			card_rewards.append(ObjManager.get_rand_shield_obj())

	for reward in card_rewards:
		%LootContainer.add_child(reward)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("continue"):
		self.queue_free()
		Game.next_room()

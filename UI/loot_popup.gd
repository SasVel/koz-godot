extends Control
class_name LootPopup

signal finished

func _ready() -> void:
	UIHelper.set_theme_colors(self)
	self.theme_changed.emit()
	var card_rewards = ObjManager.get_rand_rewards(3)
	Game.cards_layer.layer = 10

	for reward in card_rewards:
		%LootContainer.add_child(reward)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("continue"):
		get_viewport().set_input_as_handled()
		close()

func _on_continue_btn_pressed() -> void:
	close()

func close():
	Game.cards_layer.layer = 1
	finished.emit()
	self.queue_free()

extends Room
class_name DialogueRoom

func try_activate_dialogue():
	if dialogue == null: return
	var balloon = DialogueManager.show_dialogue_balloon(dialogue, "start")
	await balloon.ready
	balloon.responses_menu.response_selected.connect(_response_selected)

	await DialogueManager.dialogue_ended

func _response_selected(response : DialogueResponse):
	pass

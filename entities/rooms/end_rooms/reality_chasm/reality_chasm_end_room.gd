extends Room

func try_activate_dialogue():
	if dialogue == null: return
	var balloon = DialogueManager.show_dialogue_balloon(dialogue, "start")
	await balloon.ready
	balloon.responses_menu.response_selected.connect(_response_selected)

	await DialogueManager.dialogue_ended

func _response_selected(response : DialogueResponse):
	if response.tags.is_empty(): return
	for tag in response.tags:
		if tag == "win_game":
			print("you won!")
			UI.show_game_over_screen(true)
		elif tag == "next_room":
			Game.next_room()

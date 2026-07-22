extends DialogueRoom

func _response_selected(response : DialogueResponse):
	if response.tags.is_empty(): return
	for tag in response.tags:
		if tag == "win_game":
			print("you won!")
			UI.show_game_over_screen(true)
		elif tag == "next_room":
			Game.next_room()

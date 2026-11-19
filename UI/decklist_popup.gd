extends GamePopup

func _ready() -> void:
	get_tree().paused = true
	config()

func close():
	get_tree().paused = false
	super.close()
	self.queue_free()

func config():
	var card_datas = Game.player.cards_deck.duplicate()
	card_datas.append_array(Game.player.cards_hand)
	for data in card_datas:
		var card = ObjManager.get_card_obj(data)
		card.curr_card_state = card.CardState.Display
		%DeckGrid.add_child(card)

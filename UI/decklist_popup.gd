extends Control

func _ready() -> void:
	config()

func config():
	var card_datas = Game.player.cards_deck
	card_datas.append_array(Game.player.cards_hand)
	for data in card_datas:
		var card = ObjManager.get_card_obj(data)
		card.isLoot = true
		%DeckGrid.add_child(card)

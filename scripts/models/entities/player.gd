extends Entity
class_name Player

func _ready() -> void:
	super()
	config_deck()

func config_deck():
	cards_deck = ObjManager.get_rand_actions_datas(card_deck_size)
	draw_hand()

func start_turn():
	stats.Tempo.reset()

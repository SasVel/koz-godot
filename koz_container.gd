extends HBoxContainer

func _ready() -> void:
	Game.on_new_room.connect(set_koz_suit_visuals)

func set_koz_suit_visuals():
	%KozIconRect.texture = ObjManager.get_suit_sprite(Game.curr_room.koz_suit)
	%KozIconRect.self_modulate = ObjManager.get_suit_color(Game.curr_room.koz_suit)

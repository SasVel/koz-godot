extends HBoxContainer

func _ready() -> void:
	Game.koz_suit_changed.connect(set_koz_suit_visuals)
	Game.on_new_room.connect(func(): set_koz_suit_visuals(Game.curr_room.koz_suit))

func set_koz_suit_visuals(type : Const.SuitTypes):
	%KozIconRect.texture = ObjManager.get_suit_sprite(type)
	%KozIconRect.self_modulate = ObjManager.get_suit_color(type)

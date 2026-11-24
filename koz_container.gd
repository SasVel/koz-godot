extends HBoxContainer

func _ready() -> void:
	Game.koz_suit_changed.connect(set_koz_suit_visuals)
	Game.on_new_room.connect(func(): set_koz_suit_visuals(Game.curr_room.koz_suit))

func set_koz_suit_visuals(type : Const.SuitTypes):
	var suit_sprite = ObjManager.get_suit_sprite(type)
	%KozIconRect.texture = suit_sprite
	%KozIconRect.self_modulate = ObjManager.get_suit_color(type)
	set_koz_outline(suit_sprite)

func set_koz_outline(suit_sprite):
	%KozIconOutline.texture = suit_sprite
	var outline_color = Const.ACCENT_COLOR
	outline_color.a = 0.6
	%KozIconOutline.material.set_shader_parameter("custom_color", outline_color)

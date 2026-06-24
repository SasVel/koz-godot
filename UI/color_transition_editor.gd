extends Node

func _ready() -> void:
	set_colors_palette()
	Const.palette_changed.connect(set_colors_palette)

func set_colors_palette():
	get_parent().base_color = Const.BACKGROUND_DARKER_COLOR.darkened(0.2)

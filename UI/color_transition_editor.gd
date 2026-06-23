extends Node

func _ready() -> void:
	get_parent().base_color = Const.BACKGROUND_DARKER_COLOR.darkened(0.2)

extends Node

func _ready() -> void:
	get_parent().base_color = Const.BACKGROUND_DARKER.darkened(0.2)

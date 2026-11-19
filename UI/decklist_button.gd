extends TextureButton

func _ready() -> void:
	self.modulate = Const.COMPLIMENTARY_COLOR

func _on_pressed() -> void:
	UI.show_screen(UI.Popups.DECKLIST)

extends TextureRect

func _on_player_configured(player) -> void:
	config(player)

func config(player):
	self.texture = ObjManager.get_class_hand(player.data.player_class)
	self.modulate = Const.PRIMARY_COLOR

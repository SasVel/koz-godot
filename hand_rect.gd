extends TextureRect

@export var is_left : bool = false
var offset = 10
@onready var offset_pos : Vector2 = Vector2(offset, offset) if is_left else Vector2(-offset, offset)

func _on_player_configured(player) -> void:
	config(player)

func config(player):
	self.texture = ObjManager.get_class_hand(player.data.player_class)
	self.modulate = Const.PRIMARY_COLOR
	tween_move()

func tween_move():
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR).set_loops()
	tween.tween_property(self, "offset_transform_position", offset_pos, 1)
	tween.tween_property(self, "offset_transform_position", Vector2.ZERO, 1)

extends TextureRect
class_name ActionMiniDisplay

@export var is_colored_outline : bool = true
@onready var data : CardData

func config(data_ : CardData):
	data = data_

	var color = ObjManager.get_action_color(data.actionType)
	self.texture = ObjManager.get_action_mini_sprite(data.actionType)

	self.modulate = color
	if is_colored_outline:
		%NumLabel.label_settings.outline_color = color
	data.generic_val_changed.connect(func(x): update(x))
	update(data.get_generic_value())
	return self

func update(num):
	%NumLabel.text = str(snapped(num, 1))

func tween_activate():
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.2)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.3)
	await tween.finished

extends TextureProgressBar
class_name RadialDisplay

@onready var default_scale = self.scale

func _ready() -> void:
	self.modulate = Const.ACCENT_COLOR

func config(val, max_val):
	self.max_value = max_val
	update(val)

func update(val):
	value = val
	%Label.text = "%.f" % val

func tween_start():
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "scale", default_scale, 0.3).from(Vector2.ZERO)
	await tween.finished

func tween_stop():
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.3).from(default_scale)
	await tween.finished

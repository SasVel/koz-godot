extends Control

@export var isMaxVal : bool = false
@export var is_colored_outline : bool = true
var display_stat : Stat

func config(color : Color, stat : Stat):
	%IconRect.modulate = color
	if is_colored_outline:
		%NumLabel.label_settings.outline_color = color
	display_stat = stat

	stat.stat_changed.connect(func(_x, _y): update())
	if isMaxVal:
		stat.max_stat_changed.connect(func(_x, _y): update())

	update()
	return self

func update():
	%NumLabel.text = ""
	%NumLabel.text += str(snapped(display_stat.value, 1))
	if isMaxVal:
		%NumLabel.text += "/%s" % str(snapped(display_stat.maxValue, 1))
	tween_update()

func tween_update():
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(%IconRect, "scale", Vector2(1.2, 1.2), 0.4)
	tween.parallel().tween_property(%NumLabel, "scale", Vector2(1.2, 1.2), 0.4)

	tween.tween_property(%IconRect, "scale", Vector2.ONE, 0.3)
	tween.parallel().tween_property(%NumLabel, "scale", Vector2.ONE, 0.3)

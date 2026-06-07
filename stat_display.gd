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

func update():
	%NumLabel.text = ""
	%NumLabel.text += str(snapped(display_stat.value, 1))
	if isMaxVal:
		%NumLabel.text += "/%s" % str(snapped(display_stat.maxValue, 1))

extends HBoxContainer

@export var isMaxVal : bool = false
var display_stat : Stat

func config(color : Color, stat : Stat):
	%IconRect.modulate = color
	%NumLabel.label_settings.font_color = color
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

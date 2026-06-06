extends HBoxContainer

func config(color : Color, start_val : int, sig : Signal):
	%IconRect.modulate = color
	%NumLabel.label_settings.font_color = color
	sig.connect(func(_x, y): update(y))
	update(start_val)

func update(num):
	%NumLabel.text = str(snapped(num, 1))

extends MiniDisplay

@export var is_colored_outline : bool = true

func config(color : Color, start_val : int, sig : Signal):
	%IconRect.modulate = color
	if is_colored_outline:
		%NumLabel.label_settings.outline_color = color
	sig.connect(func(_x, y): update(y))
	update(start_val)
	return self

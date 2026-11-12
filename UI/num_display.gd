extends MiniDisplay

func config(color : Color, start_val : int, sig : Signal):
	%IconRect.modulate = color
	sig.connect(func(_x, y): update(y))
	update(start_val)
	return self

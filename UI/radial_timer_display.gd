extends TextureProgressBar
class_name RadialDisplay

func config(val, max_val):
	self.max_value = max_val
	self.value = val

func update(val):
	value = val

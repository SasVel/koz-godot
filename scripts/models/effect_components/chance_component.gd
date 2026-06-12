extends ComponentsData
class_name ChanceComponent

@export_range(0, 1, 0.01) var chance : float = 0.2

func activate():
	if randf_range(0, 1) <= chance:
		super()

func generate_desc() -> String:
	return "%.f%% chance to %s" % [chance * 100, super()]

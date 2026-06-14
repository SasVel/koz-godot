extends EffectComponent
class_name DurabilityProcessorComp

@export_range(0, 1, 0.01) var negation_chance : float = 0.2

signal failed

func activate() -> bool:
	if randf_range(0, 1) <= negation_chance:
		super()
		return true
	else:
		failed.emit()
		return false

func generate_desc() -> String:
	return "%.f%% chance to not reduce durability." % [negation_chance * 100]

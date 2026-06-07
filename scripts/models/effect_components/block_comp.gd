extends EffectComponent
class_name BlockComp

func _init() -> void:
	self.isOffensive = false
	self.ticker = "BLOCK"

func activate():
	for unit in get_affected_units():
		unit.stats.Block.value += get_full_value() 

func generate_desc() -> String:
	return "Gain %s BLOCK" % get_full_value()

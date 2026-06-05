extends EffectComponent
class_name DamageComp

func _init() -> void:
	self.isOffensive = true
	self.ticker = "DMG"

func activate():
	for unit in get_affected_units():
		unit.stats.Health.value -= get_full_value() 
		

func generate_desc() -> String:
	return "Deal %s %s." % [get_full_value(), self.ticker]

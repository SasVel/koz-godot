extends EffectComponent
class_name TempoComp

func _init() -> void:
	self.isOffensive = false
	self.ticker = "TEMPO"

func activate():
	for unit in get_affected_units():
		unit.stats.Tempo.value += value

func generate_desc() -> String:
	return "%s %s %s." % \
		["Gain" if value > 0 else "Lose", 
		str(value * -1 if value < 0 else value), 
		ticker]

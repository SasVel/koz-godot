extends EffectComponent
class_name TempoComp

func _ready() -> void:
	self.isOffensive = false
	self.ticker = "TEMPO"

func activate():
	for unit in get_affected_units():
		unit.stats.Tempo.value += process_value(value)
		unit.hand_changed.emit(unit.cards_hand)

func generate_desc() -> String:
	var val := process_value(value)
	return "%s %s %s." % \
		["Gain" if val > 0 else "Lose",
		str(val * -1 if val < 0 else val),
		ticker]

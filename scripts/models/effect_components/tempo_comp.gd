extends EffectComponent
class_name TempoComp

func _ready() -> void:
	self.isOffensive = false
	self.ticker = "TEMPO"

func activate():
	for unit in get_affected_units():
		unit.stats.Tempo.value += value
		unit.hand_changed.emit(unit.cards_hand)

func generate_desc() -> String:
	return "%s %s %s." % \
		["Gain" if value > 0 else "Lose",
		str(value * -1 if value < 0 else value),
		ticker]

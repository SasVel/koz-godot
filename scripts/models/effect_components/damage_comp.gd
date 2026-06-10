extends EffectComponent
class_name DamageComp

func _ready() -> void:
	self.isOffensive = true
	self.ticker = "DMG"
	add_to_group("damage_components")

func activate():
	for unit in get_affected_units():
		unit.take_damage(source.process_damage_outgoing(value))

func generate_desc() -> String:
	return "Deal %s DMG." % value

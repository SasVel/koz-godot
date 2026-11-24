extends EffectComponent
class_name DamageComp

func _ready() -> void:
	self.isOffensive = true
	self.ticker = "DMG"

func activate():
	for unit in get_affected_units():
		unit.take_damage(source.process_damage_outgoing(process_value(value)))
	super()

func get_processed_dmg():
	var resVal = process_value(self.value)
	if source != null:
		resVal = source.process_damage_outgoing(resVal)
	if targets[0] != null:
		resVal = targets[0].process_damage_incoming(resVal)
	return resVal

func generate_desc() -> String:
	return "Deal %.f DMG." % (source.process_damage_outgoing(process_value(value)) \
		if source != null else process_value(value))

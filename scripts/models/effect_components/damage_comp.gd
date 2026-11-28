extends EffectComponent
class_name DamageComp

@export var damage_type : Const.DamageTypes = Const.DamageTypes.NORMAL

func _ready() -> void:
	self.isOffensive = true
	self.ticker = "DMG"

func activate():
	for unit in get_affected_units():
		unit.take_damage(source.process_damage_outgoing(process_value(value)))
	super()

func get_processed_dmg():
	var resVal = process_value(self.value)

	if damage_type == Const.DamageTypes.TRUE:
		return resVal

	if source != null:
		resVal = source.process_damage_outgoing(resVal)
	if targets[0] != null:
		resVal = targets[0].process_damage_incoming(resVal)
	return resVal

func generate_desc() -> String:
	var dmg : int
		
	match damage_type:
		Const.DamageTypes.NORMAL:
			dmg = (source.process_damage_outgoing(process_value(value)) \
					if source != null else process_value(value))
		Const.DamageTypes.TRUE:
			dmg = process_value(value)

	return "Deal %.f %sDMG." % [dmg, "" if damage_type == Const.DamageTypes.NORMAL else \
	Const.DamageTypes.keys()[damage_type] + " "]

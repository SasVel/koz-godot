extends EffectComponent
class_name RemoveStatusEffComp

## Clears status effect stacks or the whole effects by type.
## Stacks to be removed are stored in the value variable.

## If true, the selected status effects will be fully cleared.
## If false, only the stacks in the value variable will be removed from them.
@export var is_fully_cleared : bool = false

## If left blank, all status effects are targeted.
@export var types : Array[Const.StatusEffects]

func activate():
	var target = get_affected_units()[0]
	if types.is_empty():
		if is_fully_cleared:
			target.clear_status_effects()
		else:
			_reduce_stacks(target, target.status_effects)
	elif is_fully_cleared:
		for type in types:
			target.remove_status_effects_by_type(type)
	else:
		for type in types:
			_reduce_stacks(target, target.get_effects(type))
	super()

func _reduce_stacks(target : Entity, effects : Array):
	for eff in effects.duplicate():
		eff.stacks = maxi(eff.stacks - process_value(value), 0)
		if eff.stacks == 0:
			target.remove_status_effect(eff)
			eff.queue_free()

func generate_desc() -> String:
	var res = ""
	if types.is_empty():
		if is_fully_cleared:
			res += "Remove all status effects"
		else:
			res += "Reduce all status effects by %d stacks" % process_value(value)
	else:
		if is_fully_cleared:
			res += "Remove "
		else:
			res += "Reduce "
		res = UIHelper.concat_arr_to_str(res, types.map(func(x): return Const.StatusEffects.keys()[x])).trim_suffix(", ")
		if !is_fully_cleared:
			res += " by %d stacks" % process_value(value)
	res += " from %s." % ("self" if !isOffensive else "enemy")
	return res

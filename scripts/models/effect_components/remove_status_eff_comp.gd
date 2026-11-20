extends EffectComponent
class_name RemoveStatusEffComp

## Clears status effect stacks or the whole effects by type. 
## Stacks to be cleared are stored in the value variable.

## The status effects selected will be fully cleared.
## if not, only the stacks in value variable will be removed from them.
@export var is_fully_cleared : bool = false

## If left blank will remove all status effects.
@export var types : Array[Const.StatusEffects]

func activate():
	var target = get_affected_units()[0]
	if types.is_empty():
		target.clear_status_effects()
		return
	elif is_fully_cleared:
		for type in types:
			target.remove_status_effects_by_type(type)
		return
	
	for type in types:
		var effects = target.get_effects(type)
		for eff in effects:
			eff.stacks -= self.value

func generate_desc() -> String:
	var res = ""
	if types.is_empty():
		res += "Remove all status effects "
	else:
		res += ("Reduce with %.f " % value) if !is_fully_cleared else ("Remove ")
		UIHelper.concat_arr_to_str(res, types.map(func(x): return Const.StatusEffects.keys()[x]))
	res += " from %s" % "self" if !isOffensive else "from enemy."
	return res

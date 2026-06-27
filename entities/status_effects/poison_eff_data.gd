@tool
extends StatusEffData

## For the poison status effect duration IS stacks. Strength of the status effect
## is dependant of the number of stacks accumulated. Stacks property is unused.

func try_stack_effect(effect : StatusEffData) -> bool:
	if self.type == effect.type:
		self.duration += effect.duration
		return true
	return false

func activate_eff():
	if %Components.get_child_count() > 0:
		for component in %Components.get_children():
			for i in range(duration):
				component.activate()
	if duration != -1:
		duration -= 1

	activated.emit()

func generate_eff_desc() -> String:
	var eff_desc = ObjManager.get_effect_description(type)
	eff_desc = eff_desc.replace("?", ("%.fx" % duration if duration > 1 else "") + str(value))
	return eff_desc

func generate_desc() -> String:
	return "Add %s %s to %s." % [
		str(duration),
		Const.StatusEffects.keys()[type],
		"self" if !isOffensive else "opponent"
	]

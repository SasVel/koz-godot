@tool
extends ComponentsData
class_name StatusEffData

@export var type : Const.StatusEffects
@export var stacks : int = 1 :
	set(val):
		stacks = val
		stacks_changed.emit(val)

## Duration of -1 is infinite.
@export var duration : int = -1 :
	set(val):
		duration = val
		if val == 0:
			self.depleted.emit(self)
			delete()
		else:
			self.duration_changed.emit(val)

signal duration_changed(val)
signal stacks_changed(val)
signal depleted(eff)

func activate():
		get_affected_units()\
			.all(func(x): x.add_status_effect(self.duplicate()))

func activate_eff():
	if %Components.get_child_count() > 0:
		for component in %Components.get_children():
			for i in range(stacks):
				component.activate()
	if duration != -1:
		duration -= 1

	activated.emit()

func try_stack_effect(effect : StatusEffData) -> bool:
	if self.type == effect.type and self.duration == effect.duration:
		self.stacks += effect.stacks
		return true
	return false

func config_comp(component : EffectComponent, source_ : Entity, targets_ : Array[Entity]):
	super(component, source_, targets_)
	component.value = value
	component.isOffensive = isOffensive

func generate_desc() -> String:
	return "Add %s %s to %s." % [
		str(stacks),
		Const.StatusEffects.keys()[type],
		"self" if !isOffensive else "opponent"
	]

func generate_eff_desc() -> String:
	var eff_desc = ObjManager.get_effect_description(type)
	eff_desc = eff_desc.replace("?", ("%.fx" % stacks if stacks > 1 else "") + str(value))
	return eff_desc

func delete():
	source.remove_status_effect(self)

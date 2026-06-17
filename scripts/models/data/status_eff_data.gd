@tool
extends ComponentsData
class_name StatusEffData

@export var type : Const.StatusEffects
@export var stacks : int = 1
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

func config_comp(component : EffectComponent, source_ : Entity, targets_ : Array[Entity]):
	super(component, source_, targets_)
	component.value = value
	component.isOffensive = isOffensive

func generate_desc() -> String:
	return "Add %s %s to %s." % [
		str(stacks),
		Const.StatusEffects.keys()[type],
		"self" if !isOffensive else "enemy"
	]

func delete():
	source.remove_status_effect(self)

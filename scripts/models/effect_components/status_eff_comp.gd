extends EffectComponent
class_name StatusEffComp

@export var type : Const.StatusEffects
@export var stacks : int = 1
@onready var data : StatusEffData

func config(source_ : Entity, targets_ : Array[Entity]):
	super(source_, targets_)
	data.config(source_, targets_)
	return self

func _init() -> void:
	data = ObjManager.status_effects_dict[type].instantiate()
	data.stacks = stacks
	value = data.value

func get_full_value() -> int:
	return process_value(data.value)

func config_source(source_ : Entity):
	super(source_)
	data.source = source_

func add_target(target_ : Entity):
	super(target_)
	data.add_target(target_)

func add_targets(targets_ : Array[Entity]):
	super(targets_)
	data.add_targets(targets_)

func _activate_data():
	var bonus := get_suit_bonus()
	var prev_stacks := data.stacks
	var prev_value := data.value
	data.stacks += bonus
	data.value += bonus
	data.activate()
	data.stacks = prev_stacks
	data.value = prev_value

func activate():
	_activate_data()

func deactivate():
	_activate_data()

func generate_desc() -> String:
	return "Add %s %s." %\
	[str(process_value(stacks)),
	Const.StatusEffects.keys()[data.type]]

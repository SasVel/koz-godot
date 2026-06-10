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
	return data.value + data.bonus_value

func config_source(source_ : Entity):
	super(source_)
	data.source = source_

func add_target(target_ : Entity):
	super(target_)
	data.add_target(target_)

func add_targets(targets_ : Array[Entity]):
	super(targets_)
	data.add_targets(targets_)

func activate():
	data.activate()

func deactivate():
	data.activate()

func generate_desc() -> String:
	return "Add %s %s." %\
	[str(stacks),
	Const.StatusEffects.keys()[data.type]]

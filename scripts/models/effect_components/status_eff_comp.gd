extends EffectComponent
class_name StatusEffComp

@export var type : Const.StatusEffects
@onready var data : StatusEffData

func config(source_ : Entity, targets_ : Array[Entity]):
	data.config(source_, targets_)

func _ready() -> void:
	data = ObjManager.status_effects_dict[type].instantiate()
	value = data.value

func get_full_value() -> int:
	return data.value + data.bonus_value

func activate():
	data.activate()

func deactivate():
	data.activate()

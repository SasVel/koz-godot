extends Node
class_name EffectComponent

@export var value : int = 10
@export var bonus_value : int = 0
@export var isOffensive : bool = true
@onready var ticker : String = "NULL"

@onready var source : Entity
@onready var targets : Array[Entity]

func config(source_ : Entity, targets_ : Array[Entity]):
	source = source_
	targets = targets_

func activate():
	pass

func deactivate():
	pass

func can_activate():
	return true

func get_affected_units() -> Array[Entity]:
	return self.targets if self.isOffensive else [self.source]

func get_full_value() -> int:
	return value + bonus_value

func generate_desc() -> String:
	return ""

extends Node
class_name EffectComponent

@export var value : int = 10
@export var isOffensive : bool = true
@onready var ticker : String = "NULL"

@onready var source : Entity
@onready var targets : Array[Entity]

func config(source_ : Entity, targets_ : Array[Entity]):
	config_source(source_)
	add_targets(targets_)
	return self

func config_source(source_ : Entity):
	source = source_

func activate():
	pass

func deactivate():
	pass

func can_activate():
	return true

func add_target(target_ : Entity):
	targets.append(target_)

func add_targets(targets_ : Array[Entity]):
	targets.append_array(targets)

func get_affected_units() -> Array:
	return self.targets if self.isOffensive else [self.source]

func generate_desc() -> String:
	return ""

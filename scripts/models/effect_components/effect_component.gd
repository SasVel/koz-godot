extends Node
class_name EffectComponent

@export var value : int = 10
@export var isOffensive : bool = true
@onready var ticker : String = "NULL"

@onready var source : Entity
@onready var targets : Array[Entity]

signal activated
signal deactivated

func config(source_ : Entity, targets_ : Array[Entity]):
	config_source(source_)
	add_targets(targets_)
	return self

func config_source(source_ : Entity):
	source = source_

func activate():
	activated.emit()

func deactivate():
	deactivated.emit()

func can_activate():
	return true

func add_target(target_ : Entity):
	if targets.has(target_): return
	targets.append(target_)

func add_targets(targets_ : Array[Entity]):
	for target in targets_:
		add_target(target)

func get_affected_units() -> Array:
	if self.targets.size() <= 0:
		return [self.source]
	elif self.source == null:
		return self.targets
	return (self.targets if self.isOffensive else [self.source]).filter(func(x): return x != null)

func generate_desc() -> String:
	return ""

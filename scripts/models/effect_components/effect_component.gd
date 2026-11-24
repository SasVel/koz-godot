extends Node
class_name EffectComponent

@export var value : int = 10
@export var isOffensive : bool = true
@onready var ticker : String = "NULL"

@onready var source : Entity
@onready var targets : Array[Entity]

@export var sound : SFX.Sounds

signal activated
signal deactivated

func config(source_ : Entity, targets_ : Array[Entity]):
	config_source(source_)
	add_targets(targets_)
	return self

func config_source(source_ : Entity):
	source = source_

var _card_owner : CardData
var card_owner_set : bool = false

func set_card_owner():
	if card_owner_set: return
	var node := get_parent()
	while node != null:
		if node is CardData:
			_card_owner = node
			break
		node = node.get_parent()
	card_owner_set = true

func process_value(value_ : int) -> int:
	set_card_owner()
	return _card_owner.process_value(value_) if _card_owner != null else value_

func get_processed_value() -> int:
	return process_value(value)

func get_suit_bonus() -> int:
	set_card_owner()
	return _card_owner.get_suit_bonus() if _card_owner != null else 0

func activate():
	if sound != null:
		SFX.play(sound)
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

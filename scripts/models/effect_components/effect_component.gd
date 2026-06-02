extends Node
class_name EffectComponent

@export var isOffensive : bool 

@onready var source : Entity
@onready var targets : Array[Entity]

func activate():
	pass

func deactivate():
	pass

func can_activate():
	return true

func get_affected_unit():
	return self.target if self.isOffensive else self.source

func generate_desc() -> String:
	return ""

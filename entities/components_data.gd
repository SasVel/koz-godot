@tool
extends Node
class_name ComponentsData

@onready var source : Entity

signal activated
signal deactivated

func config_source(source_ : Entity):
	source = source_
	for component in %Components.get_children():
		component.config_source(source_)

func add_target(target_ : Entity):
	for component in %Components.get_children():
		component.add_target(target_)

func add_targets(targets_ : Array[Entity]):
	for component in %Components.get_children():
		component.add_targets(targets_)

func config(source_ : Entity, targets_ : Array[Entity]):
	for component in %Components.get_children():
		config_comp(component, source_, targets_)

func config_comp(component : EffectComponent, source_ : Entity, targets_ : Array[Entity]):
	component.config(source_, targets_)

func activate():
	for component in %Components.get_children():
		component.activate()
	activated.emit()

func deactivate():
	for component in %Components.get_children():
		component.deactivate()
	deactivated.emit()

func generate_desc() -> String:
	var resArr : Array[String]
	for component in %Components.get_children():
		resArr.append(component.generate_desc())

	return "\n".join(resArr) if resArr.size() > 0 else ""

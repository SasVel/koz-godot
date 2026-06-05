@tool
extends Node
class_name CardData

@export var type : Const.CardTypes = Const.CardTypes.GENERIC

@export var actionType : Const.Actions 
@export var weaponType : Const.Weapons
@export var shieldType : Const.Shields

@export var tempoCost : int = 1

signal activated
signal deactivated

func config_source(source_ : Entity):
	for component in %Components.get_children():
		component.source = source_

func add_target(target_ : Entity):
	for component in %Components.get_children():
		component.targets.append(target_)

func config(source_ : Entity, targets_ : Array[Entity]):
	for component in %Components.get_children():
		component.config(source_, targets_)

func activate():
	for component in %Components.get_children():
		component.activate()
	activated.emit()

func deactivate():
	for component in %Components.get_children():
		component.deactivate()
	deactivated.emit()

func can_activate():
	return true

func generate_desc() -> String:
	var resArr : Array[String]
	for component in %Components.get_children():
		resArr.append(component.generate_desc())

	return "\n".join(resArr) if resArr.size() > 0 else ""

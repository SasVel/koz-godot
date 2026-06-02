extends Node
class_name CardData

@export var type : Const.CardTypes = Const.CardTypes.GENERIC

func activate():
	for component in %Components.get_children():
		component.activate()

func deactivate():
	for component in %Components.get_children():
		component.deactivate()

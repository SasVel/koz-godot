@tool
extends CardData
class_name ToolData

@export_range(0, 8) var durability : int = 4 :
	set(val):
		durability = val
		durability_changed.emit(val)

signal durability_changed(val)

func activate():
	super()
	durability -= 1

func can_activate():
	return super() and durability > 0

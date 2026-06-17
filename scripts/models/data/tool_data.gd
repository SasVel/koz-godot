extends CardData
class_name ToolData

@export_range(0, 8) var durability : int = 4 :
	set(val):
		durability = val
		if durability <= 0:
			source.remove_tool(self)
		durability_changed.emit(val)

@export var durability_processor : DurabilityProcessorComp

signal durability_changed(val)

func activate(deduct_tempo : bool = true):
	super()
	if deduct_tempo:
		durability -= process_durability_loss(1)

func can_activate():
	return super() and durability > 0

func process_durability_loss(num):
	if durability_processor == null: return num
	return 0 if durability_processor.activate() else num

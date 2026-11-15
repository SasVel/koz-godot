extends CardObj
class_name Tool

func _ready() -> void:
	super()

func config(data_ : CardData):
	super(data_)
	var tool_data = data_ as ToolData
	tool_data.durability_changed.connect(update_durability)
	update_durability(tool_data.durability)
	return self

func update_durability(val):
	%DurabilityLabel.text = "|"
	for i in range(val):
		%DurabilityLabel.text += "#"
	%DurabilityLabel.text += "|"

func _can_drop_data(at_position: Vector2, drop_data: Variant) -> bool:
	if !super(at_position, drop_data): return false
	return drop_data["object"].data is ToolData

func _drop_data(_at_position: Vector2, drop_data: Variant) -> void:
	var loot_data = drop_data["object"].data
	if loot_data is not ToolData: return
	(data.source as Player).replace_tool(loot_data.duplicate(), self.data)
	drop_data["object"].queue_free()

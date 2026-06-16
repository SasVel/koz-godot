extends CardObj
class_name Tool

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

func _drop_data(at_position: Vector2, drop_data: Variant) -> void:
	(data.source as Player).replace_tool(drop_data["object"].data.duplicate(), self.data)
	drop_data["object"].queue_free()

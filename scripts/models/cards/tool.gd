extends CardObj
class_name Tool

func _ready() -> void:
	var tool_data = data as ToolData
	tool_data.durability_changed.connect(update_durability)
	update_durability(tool_data.durability)
	
func update_durability(val):
	%DurabilityLabel.text = "/"
	for i in range(val):
		%DurabilityLabel.text += "~"
	%DurabilityLabel.text += "/"

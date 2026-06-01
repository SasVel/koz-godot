extends CardObj
class_name Tool

func _ready() -> void:
	init(null)

func init(data):
	%IconRect.modulate = Const.TOOL_COLOR

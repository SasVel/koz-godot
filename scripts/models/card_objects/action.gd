extends CardObj
class_name Action

func _ready() -> void:
	init(null)

func init(data):
	%IconRect.modulate = Const.ACTION_COLOR

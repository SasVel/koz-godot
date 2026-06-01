extends Sprite3D
class_name Entity

@export var defaultStats : StatBlock
var stats : StatBlock

func _ready() -> void:
	stats = defaultStats.duplicate()

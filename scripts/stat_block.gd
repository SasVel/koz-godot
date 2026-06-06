extends Resource
class_name StatBlock

@export var Health : Stat = Stat.new()
@export var Block : Stat = Stat.new()
@export var Tempo : Stat = Stat.new()

func _init() -> void:
	# Block is always capped to current Health.
	Health.stat_changed.connect(\
	func(_old, new): Block.maxValue = new)

extends Resource
class_name StatBlock

@export var Health : Stat = Stat.new()
@export var Block : Stat = Stat.new()
@export var Tempo : Stat = Stat.new()
@export var HandSize : Stat = Stat.new()

func _init() -> void:
	# Block is always capped to current Health.
	Health.stat_changed.connect(\
	func(_old, new): Block.maxValue = new)

func take_damage(val : int):
	if Block.value > 0:
		if Block.value <= val:
			val -= Block.value
			Block.value = 0
		else:
			Block.value -= val
			return
	if val == 0: return

	Health.value -= val

func reset():
	Health.value = Health.maxValue
	Block.value = 0
	Tempo.value = Tempo.maxValue

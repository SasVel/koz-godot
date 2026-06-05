extends Entity
class_name Enemy

@export var type : Const.Enemies

func _ready() -> void:
	super()
	stats.Health.max_stat_changed.connect(\
		func(oldVal, newVal): %HealthBar.max_value = newVal)
	stats.Health.stat_changed.connect(\
		func(oldVal, newVal): %HealthBar.value = newVal)

	%HealthBar.max_value = stats.Health.maxValue
	%HealthBar.value = stats.Health.value

func _on_mouse_entered() -> void:
	pass


func _on_data_dropper_data_dropped(at_position: Vector2, data: Variant) -> void:
	var card_data = data["object"].data
	card_data.add_target(self)
	card_data.activate()

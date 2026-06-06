extends Entity
class_name Enemy

@export var type : Const.Enemies

func _ready() -> void:
	super()
	%EnemyBar.config(stats.Health, stats.Block)

func _on_mouse_entered() -> void:
	pass


func _on_data_dropper_data_dropped(at_position: Vector2, data: Variant) -> void:
	var card_data = data["object"].data
	card_data.add_target(self)
	card_data.activate()

extends Entity
class_name Enemy

@export var type : Const.Enemies

func _ready() -> void:
	super()
	%EnemyBar.config(stats.Health, stats.Block)
	%EnemySprite.modulate = Const.ENEMY_COLORS[Const.Enemies.keys()[type]]

func _on_data_dropper_data_dropped(_at_position: Vector2, data: Variant):
	var card_data = data["object"].data
	card_data.add_target(self)
	card_data.activate()

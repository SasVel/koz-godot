extends Entity
class_name Enemy

func config(data_ : EntityData):
	super(data_)
	%IdleAnimator.config((data as EnemyData).idle_anim_settings)
	%NameLabel.text = data.entity_name
	%EnemyBar.config(stats.Health, stats.Block)
	%EnemySprite.texture = ObjManager.get_enemy_sprite(data.type, data.has_alt_sprite)
	%EnemySprite.modulate = Const.ENEMY_COLORS[Const.Enemies.keys()[data.type]]
	return self

func _on_data_dropper_data_dropped(_at_position: Vector2, data: Variant):
	var card_data = data["object"].data
	card_data.add_target(self)
	card_data.activate()

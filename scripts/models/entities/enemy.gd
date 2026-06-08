extends Entity
class_name Enemy

func _ready() -> void:
	super()
	data.card_hand_size = stats.Tempo.maxValue
	stats.Tempo.max_stat_changed.connect(func(_old, new): data.card_hand_size = new)
	Game.on_start_turn.connect(draw_hand)
	Game.enemy_actions.append(activate_actions_hand)
	draw_hand()

func config(data_ : EntityData):
	super(data_)
	%IdleAnimator.config((data as EnemyData).idle_anim_settings)
	%NameLabel.text = data.entity_name
	%EnemyBar.config(stats.Health, stats.Block)
	%EnemySprite.texture = ObjManager.get_enemy_sprite(data.type, data.has_alt_sprite)
	%EnemySprite.modulate = Const.ENEMY_COLORS[Const.Enemies.keys()[data.type]]
	return self

func _on_data_dropper_data_dropped(_at_position: Vector2, 
	drop_data: Variant):
	var card_data = drop_data["object"].data
	card_data.add_target(self)
	card_data.activate()

func add_action_deck(action : CardData):
	super(action)
	action.config(self, [Game.player])

func activate_actions_hand():
	for idx in range(cards_hand.size()):
		var action = cards_hand[0]
		await %ActionsDisplay.tween_action(action)
		action.activate()
		await get_tree().create_timer(0.2).timeout

func on_death():
	await tween_death()
	Game.enemy_actions.erase(activate_actions_hand)
	queue_free()

func tween_death():
	%IdleAnimator.stop()
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(%EnemySprite, "rotation_degrees", 90, 0.5)
	await tween.finished

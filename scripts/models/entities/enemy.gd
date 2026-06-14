extends Entity
class_name Enemy

func _ready() -> void:
	data.card_hand_size = stats.Tempo.maxValue
	stats.Tempo.stat_changed.connect(\
		func(_old, new):
			data.card_hand_size = new
			reduce_actions_hand_to_hand_size())
	Game.enemy_actions.append(activate_actions_hand)
	super()

func config(data_ : EntityData):
	super(data_)
	%IdleAnimator.config((data as EnemyData).idle_anim_settings)
	%NameLabel.text = data.entity_name
	%EnemyBar.config(stats.Health, stats.Block)
	%EnemySprite.texture = ObjManager.get_enemy_sprite(data.type, data.has_alt_sprite)
	%EnemySprite.modulate = Const.ENEMY_COLORS[Const.Enemies.keys()[data.type]]
	return self

func _on_data_dropper_data_dropped(at_position: Vector2, drop_data: Variant):
	var card_obj : CardObj = drop_data["object"]
	card_obj.data.add_target(self)
	await card_obj.activate(at_position)

func add_action_deck(action : CardData):
	action.config(self, [Game.player])
	super(action)

func activate_actions_hand():
	for idx in range(cards_hand.size()):
		var action = cards_hand.get(0)
		if action == null: return

		await %ActionsDisplay.tween_action(action)
		action.activate()
		await get_tree().create_timer(0.2).timeout

func reduce_actions_hand_to_hand_size():
	if cards_hand.size() <= data.card_hand_size: return
	var diff = cards_hand.size() - data.card_hand_size
	for i in range(diff):
		move_action_to_deck(cards_hand[0])

func on_death():
	await tween_death()
	queue_free()

func _exit_tree() -> void:
	Game.enemy_actions.erase(activate_actions_hand)

func tween_death():
	%IdleAnimator.stop()
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(%EnemySprite, "rotation_degrees", 90, 0.5)
	await tween.finished

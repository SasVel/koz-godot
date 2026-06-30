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
	var enemy_data = data as EnemyData
	%IdleAnimator.config(enemy_data.idle_anim_settings)
	%NameLabel.text = data.entity_name
	%EnemyBar.config(stats.Health, stats.Block)
	var enemy_sprite = ObjManager.get_enemy_sprite(data.type, data.has_alt_sprite)
	if enemy_data.custom_scale_multi != 1.0:
		%EnemySprite.scale *=  enemy_data.custom_scale_multi
	%EnemySprite.texture = enemy_sprite
	%SpriteShadow.texture = enemy_sprite
	%EnemySprite.modulate = ObjManager.get_enemy_color(data.type)
	var ability_desc = data.generate_desc()
	if ability_desc == "":
		%SpecialAbilityLabel.visible = false
	else:
		%SpecialAbilityLabel.visible = true
		var desc = data.generate_desc()
		%SpecialAbilityLabel.text = desc
		%DataDropper.tooltip_text = desc
	enemy_data.enemy_config(self, [Game.player])
	data.activate()
	return self

func on_changed_phase(val : Game.Phases):
	if val == Game.Phases.ATTACK:
		apply_defend_phase_modifiers()
	elif val == Game.Phases.DEFEND:
		apply_attack_phase_modifiers()

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

func take_damage(dmg : int):
	super(dmg)
	var hit_eff : HitEffect = ObjManager.hit_eff_scn.instantiate()
	self.add_child(hit_eff)
	hit_eff.position = Vector2((hit_eff.size / 2) * -1)
	%IdleAnimator.pause()
	await %HitAnimator.play()
	%IdleAnimator.play()

func on_death():
	await tween_death()
	queue_free()

func _exit_tree() -> void:
	Game.enemy_actions.erase(activate_actions_hand)
	data.deactivate()

func tween_death():
	%IdleAnimator.stop()
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(%EnemySprite, "rotation_degrees", 90, 0.5)
	await tween.finished

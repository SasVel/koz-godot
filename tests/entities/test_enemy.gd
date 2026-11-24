extends GutTest

## Tests for scripts/models/entities/enemy.gd.
##
## The real enemy.tscn is used, but the animation/display nodes are swapped for
## no-op stubs so tests are fast and deterministic. Autoload state is reset
## around every test (see tests/entities/helpers/state.gd).

const ENEMY_SCENE := preload("res://entities/enemy.tscn")

const ANIM_STUB := preload("res://tests/entities/stubs/animator_stub.gd")
const BAR_STUB := preload("res://tests/entities/stubs/bar_stub.gd")
const ACTIONS_STUB := preload("res://tests/entities/stubs/actions_display_stub.gd")
const STATUS_STUB := preload("res://tests/entities/stubs/status_display_stub.gd")
const DESC_STUB := preload("res://tests/entities/stubs/desc_component_stub.gd")
const PLAYER_STUB := preload("res://tests/entities/stubs/player_stub.gd")
const EMPTY_EFFECT := preload("res://tests/entities/stubs/empty_effect.tscn")

const FIXTURES := preload("res://tests/entities/helpers/fixtures.gd")
const STATE := preload("res://tests/entities/helpers/state.gd")

var _enemy: Enemy
var _data: EnemyData
var _player: Player
var _config_result
var _orig_hit_eff: PackedScene


func before_each() -> void:
	STATE.reset()

	_orig_hit_eff = ObjManager.hit_eff_scn
	ObjManager.hit_eff_scn = EMPTY_EFFECT

	# Enemy.config() passes [Game.player] into typed Array[Entity] parameters.
	_player = PLAYER_STUB.new()
	add_child(_player)
	Game.player = _player

	# Start with an empty authored deck, then add component-less cards through
	# the public API so their `activated` signal is wired up for hand tests.
	_data = FIXTURES.enemy_data(FIXTURES.stat_block(10, 0, 3))
	add_child(_data)
	_enemy = _make_enemy(_data)
	for i in range(3):
		_enemy.add_action_deck(FIXTURES.card(Const.Actions.SLASH, 1))


func after_each() -> void:
	ObjManager.hit_eff_scn = _orig_hit_eff

	if is_instance_valid(_enemy):
		STATE.cleanup_entity(_enemy)
		_enemy.free()
	_enemy = null

	if is_instance_valid(_data):
		# The second data.config() call (from enemy_config) creates a fresh set
		# of cards that are never parented; free them explicitly.
		for card in _data.card_deck:
			if is_instance_valid(card) and card.get_parent() == null:
				card.free()
		_data.free()
	_data = null

	if is_instance_valid(_player):
		_player.free()
	_player = null

	Game.player = null
	Game.event_queue.clear()
	STATE.restore()


#region Helpers
func _stub_visuals(e: Enemy) -> void:
	e.get_node("EnemySprite/IdleAnimator").set_script(ANIM_STUB)
	e.get_node("EnemySprite/HitAnimator").set_script(ANIM_STUB)
	e.get_node("EnemySprite/ActionAnimator").set_script(ANIM_STUB)
	e.get_node("VBoxContainer/VBoxContainer/EnemyBar").set_script(BAR_STUB)
	e.get_node("VBoxContainer/ActionsDisplay").set_script(ACTIONS_STUB)
	e.get_node("VBoxContainer/StatusEffectsDisplay").set_script(STATUS_STUB)


func _make_enemy(d: EnemyData) -> Enemy:
	var e: Enemy = ENEMY_SCENE.instantiate()
	_stub_visuals(e)
	# Must watch before config() because config() emits `configured`.
	watch_signals(e)
	# config() must run before add_child(): Enemy._ready() reads `stats`.
	_config_result = e.config(d)
	add_child(e)
	return e


func _dispose_current() -> void:
	if is_instance_valid(_enemy):
		STATE.cleanup_entity(_enemy)
		_enemy.free()
	_enemy = null

	if is_instance_valid(_data):
		for card in _data.card_deck:
			if is_instance_valid(card) and card.get_parent() == null:
				card.free()
		_data.free()
	_data = null


func _rebuild(d: EnemyData) -> void:
	_dispose_current()
	_data = d
	add_child(_data)
	_enemy = _make_enemy(_data)
#endregion


#region Config / visuals
func test_config_returns_self_and_emits_configured() -> void:
	assert_eq(_config_result, _enemy)
	assert_signal_emitted(_enemy, "configured")


func test_config_sets_name_sprite_and_shadow() -> void:
	assert_eq(_enemy.get_node("%NameLabel").text, "Test Enemy")

	var sprite: Sprite2D = _enemy.get_node("%EnemySprite")
	assert_true(sprite.texture != null)
	assert_eq(_enemy.get_node("%SpriteShadow").texture, sprite.texture)
	assert_eq(sprite.modulate, ObjManager.get_enemy_color(Const.Enemies.SLIME))

func test_config_shows_ability_description() -> void:
	var d := FIXTURES.enemy_data(FIXTURES.stat_block(10, 0, 3))
	var comp := Node.new()
	comp.set_script(DESC_STUB)
	d.get_node("%Components").add_child(comp)
	_rebuild(d)

	var label: Label = _enemy.get_node("%SpecialAbilityLabel")
	assert_true(label.visible)
	assert_eq(label.text, "Test ability")
	assert_eq(_enemy.get_node("%DataDropper").tooltip_text, "Test ability")


func test_config_builds_deck_from_card_deck_types() -> void:
	var types := [Const.Actions.SLASH, Const.Actions.DEFEND, Const.Actions.SMASH]
	_rebuild(FIXTURES.enemy_data(FIXTURES.stat_block(10, 0, 3), types))

	assert_eq(_enemy.cards_deck.size(), 3)
	var card_datas: Node = _enemy.get_node("%CardDatas")
	for i in range(3):
		assert_eq(_enemy.cards_deck[i].actionType, types[i])
		assert_eq(_enemy.cards_deck[i].source, _enemy)
		assert_eq(_enemy.cards_deck[i].get_parent(), card_datas)
#endregion


#region Lifecycle
func test_ready_sets_hand_size_from_tempo() -> void:
	assert_eq(_data.card_hand_size, 3)
	assert_true(Game.enemy_actions.any(func(c): return c.get_object() == _enemy))


func test_exit_tree_unregisters_action() -> void:
	STATE.cleanup_entity(_enemy)
	_enemy.free()
	_enemy = null
	assert_eq(Game.enemy_actions.size(), 0)
#endregion


#region Phase (Enemy mapping is inverted from Player)
func test_attack_phase_applies_enemy_defend_modifiers() -> void:
	_enemy.stats.Block.value = 5
	_enemy.on_changed_phase(Game.Phases.ATTACK)

	assert_eq(_enemy.stats.Tempo.maxValue, 2)
	assert_eq(_enemy.stats.Tempo.value, 2)
	assert_eq(_enemy.stats.Block.value, 5)


func test_defend_phase_applies_enemy_attack_modifiers() -> void:
	_enemy.stats.Block.value = 5
	_enemy.on_changed_phase(Game.Phases.DEFEND)

	assert_eq(_enemy.stats.Block.value, 0)
	assert_eq(_enemy.stats.Tempo.maxValue, 4)
	assert_eq(_enemy.stats.Tempo.value, 4)


func test_phase_signal_is_wired() -> void:
	_enemy.stats.Block.value = 5
	Game.on_changed_phase.emit(Game.Phases.DEFEND)

	assert_eq(_enemy.stats.Block.value, 0)
	assert_eq(_enemy.stats.Tempo.value, 4)
#endregion


#region Hand / turn
func test_tempo_change_trims_hand() -> void:
	_enemy.draw_hand()
	assert_eq(_enemy.cards_hand.size(), 3)
	assert_eq(_enemy.cards_deck.size(), 0)

	_enemy.stats.Tempo.value = 1

	assert_eq(_data.card_hand_size, 1)
	assert_eq(_enemy.cards_hand.size(), 1)
	assert_eq(_enemy.cards_deck.size(), 2)


func test_reduce_hand_is_noop_within_limit() -> void:
	_data.card_hand_size = 2
	_enemy.add_actions_hand([_enemy.cards_deck[0], _enemy.cards_deck[1]], false)
	assert_eq(_enemy.cards_hand.size(), 2)

	var deck_size := _enemy.cards_deck.size()
	_enemy.reduce_actions_hand_to_hand_size()

	assert_eq(_enemy.cards_hand.size(), 2)
	assert_eq(_enemy.cards_deck.size(), deck_size)


func test_activate_actions_hand_plays_all_cards() -> void:
	_enemy.add_actions_hand(_enemy.pop_actions_deck(2), false)
	assert_eq(_enemy.cards_hand.size(), 2)
	assert_eq(_enemy.cards_deck.size(), 1)

	Game.event_queue.clear()
	await _enemy.activate_actions_hand()

	assert_eq(_enemy.cards_hand.size(), 0)
	assert_eq(_enemy.cards_deck.size(), 3)
	assert_eq(_enemy.stats.Tempo.value, 1)
	assert_signal_emit_count(_enemy, "card_activated", 2)


func test_activate_actions_hand_noop_when_empty() -> void:
	_enemy.clear_hand()
	Game.event_queue.clear()

	await _enemy.activate_actions_hand()

	assert_signal_not_emitted(_enemy, "card_activated")


func test_add_action_deck_targets_player() -> void:
	var card: CardData = FIXTURES.card(Const.Actions.SLASH, 1)
	_enemy.add_action_deck(card)

	assert_eq(card.source, _enemy)
	assert_eq(card.targets.size(), 1)
	assert_eq(card.targets[0], _player)
	assert_true(_enemy.cards_deck.has(card))
	assert_eq(card.get_parent(), _enemy.get_node("%CardDatas"))
#endregion


#region Damage / death / targeting
func test_take_damage_uses_block_then_health() -> void:
	_enemy.stats.Block.value = 4

	await _enemy.take_damage(6)

	assert_eq(_enemy.stats.Block.value, 0)
	assert_eq(_enemy.stats.Health.value, 8)


func test_data_dropper_adds_target_and_queues_activation() -> void:
	var card: CardData = FIXTURES.card(Const.Actions.SLASH, 1)
	var card_obj: CardObj = ObjManager.get_card_obj(card)
	add_child(card_obj)
	Game.event_queue.clear()

	await _enemy._on_data_dropper_data_dropped(Vector2.ZERO, {"object": card_obj})

	assert_true(card.targets.has(_enemy))
	assert_eq(Game.event_queue.size(), 1)

	Game.event_queue.clear()
	card_obj.free()
	card.free()


func test_on_death_enqueues_death_tween_and_frees() -> void:
	STATE.cleanup_entity(_enemy)
	# Do not await: on_death() suspends on Game.event_queue_empty, which would
	# never fire because Game's physics processing is disabled in tests.
	_enemy.on_death()
	assert_eq(Game.event_queue.size(), 1)

	Game.event_queue.clear()
	Game.event_queue_empty.emit()
	await get_tree().process_frame

	var gone := not is_instance_valid(_enemy) or _enemy.is_queued_for_deletion()
	assert_true(gone, "Enemy should be freed after the death event resolves")
	_enemy = null
#endregion

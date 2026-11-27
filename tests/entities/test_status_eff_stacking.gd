extends GutTest

## Regression tests for status effect stacking in Entity.add_status_effect().
## A successful stack must survive later, non-matching effects in the list;
## otherwise poison ends up as several data objects / icons with their own
## counters instead of one object with an accumulated duration.

const ENEMY_SCENE := preload("res://entities/enemy.tscn")
const POISON_SCENE := preload("res://entities/status_effects/poison_eff_data.tscn")
const STRENGTH_SCENE := preload("res://entities/status_effects/str_eff_data.tscn")

const ANIM_STUB := preload("res://tests/entities/stubs/animator_stub.gd")
const BAR_STUB := preload("res://tests/entities/stubs/bar_stub.gd")
const ACTIONS_STUB := preload("res://tests/entities/stubs/actions_display_stub.gd")
const STATUS_STUB := preload("res://tests/entities/stubs/status_display_stub.gd")
const PLAYER_STUB := preload("res://tests/entities/stubs/player_stub.gd")
const EMPTY_EFFECT := preload("res://tests/entities/stubs/empty_effect.tscn")

const FIXTURES := preload("res://tests/entities/helpers/fixtures.gd")
const STATE := preload("res://tests/entities/helpers/state.gd")

var _enemy: Enemy
var _data: EnemyData
var _player: Player
var _orig_hit_eff: PackedScene


func before_each() -> void:
	STATE.reset()

	_orig_hit_eff = ObjManager.hit_eff_scn
	ObjManager.hit_eff_scn = EMPTY_EFFECT

	_player = PLAYER_STUB.new()
	add_child(_player)
	Game.player = _player

	_data = FIXTURES.enemy_data(FIXTURES.stat_block(10, 0, 3))
	add_child(_data)

	_enemy = ENEMY_SCENE.instantiate()
	_enemy.get_node("EnemySprite/IdleAnimator").set_script(ANIM_STUB)
	_enemy.get_node("EnemySprite/HitAnimator").set_script(ANIM_STUB)
	_enemy.get_node("EnemySprite/ActionAnimator").set_script(ANIM_STUB)
	_enemy.get_node("VBoxContainer/VBoxContainer/EnemyBar").set_script(BAR_STUB)
	_enemy.get_node("VBoxContainer/ActionsDisplay").set_script(ACTIONS_STUB)
	_enemy.get_node("VBoxContainer/StatusEffectsDisplay").set_script(STATUS_STUB)
	_enemy.config(_data)
	add_child(_enemy)


func after_each() -> void:
	ObjManager.hit_eff_scn = _orig_hit_eff

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

	if is_instance_valid(_player):
		_player.free()
	_player = null

	Game.player = null
	Game.event_queue.clear()
	STATE.restore()


func test_poison_stacks_into_one_effect() -> void:
	var first: StatusEffData = POISON_SCENE.instantiate()
	var second: StatusEffData = POISON_SCENE.instantiate()

	_enemy.add_status_effect(first)
	_enemy.add_status_effect(second)

	assert_eq(_enemy.status_effects.size(), 1, "Poison should occupy a single data object")
	assert_eq(_enemy.status_effects[0], first)
	assert_eq(first.duration, 2, "Incoming duration should be absorbed by the first object")
	assert_eq(_enemy.get_node("%EffectDatas").get_child_count(), 1)


func test_poison_stacks_when_another_effect_follows_it() -> void:
	var poison: StatusEffData = POISON_SCENE.instantiate()
	var strength: StatusEffData = STRENGTH_SCENE.instantiate()
	_enemy.add_status_effect(poison)
	_enemy.add_status_effect(strength)
	var incoming: StatusEffData = POISON_SCENE.instantiate()

	_enemy.add_status_effect(incoming)

	assert_eq(_enemy.status_effects.size(), 2, "A later, non-matching effect must not undo the stack")
	assert_eq(_enemy.get_effects(Const.StatusEffects.POISON).size(), 1)
	assert_eq(_enemy.get_effects(Const.StatusEffects.STRENGTH).size(), 1)
	assert_eq(poison.duration, 2)
	assert_eq(_enemy.get_node("%EffectDatas").get_child_count(), 2)


func test_absorbed_effect_is_freed() -> void:
	var first: StatusEffData = POISON_SCENE.instantiate()
	var incoming: StatusEffData = POISON_SCENE.instantiate()
	_enemy.add_status_effect(first)

	_enemy.add_status_effect(incoming)

	assert_false(is_instance_valid(incoming), "Throwaway duplicate should be released")
	assert_true(is_instance_valid(first))

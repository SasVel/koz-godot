extends GutTest

## Tests for the Koz-suit value bonus on card effect components.

const ROOM_STUB := preload("res://tests/entities/stubs/koz_room_stub.gd")
const FIXTURES := preload("res://tests/entities/helpers/fixtures.gd")

var _room: Room
var _card: CardData
var _source: Entity
var _orig_bonus: int


func before_each() -> void:
	_orig_bonus = Game.koz_suit_value_bonus
	Game.koz_suit_value_bonus = 5
	Game.curr_room = null

	_room = ROOM_STUB.new()
	add_child_autofree(_room)
	_room.koz_suit = Const.SuitTypes.Spades
	Game.curr_room = _room

	_source = Entity.new()
	add_child_autofree(_source)
	_source.stats = FIXTURES.stat_block(10, 0, 3)

	_card = FIXTURES.card(Const.Actions.SLASH)
	_card.suit = Const.SuitTypes.Spades
	add_child_autofree(_card)
	_card.config_source(_source)


func after_each() -> void:
	Game.curr_room = null
	Game.koz_suit_value_bonus = _orig_bonus


func _add_block_comp(value: int) -> BlockComp:
	var comp := BlockComp.new()
	comp.value = value
	_card.get_node("%Components").add_child(comp)
	comp.config(_source, [])
	return comp


func test_process_value_adds_bonus_when_suits_match() -> void:
	assert_eq(_card.process_value(10), 15)
	assert_eq(_card.get_suit_bonus(), 5)


func test_process_value_ignores_non_matching_suit() -> void:
	_card.suit = Const.SuitTypes.Hearts
	assert_eq(_card.process_value(10), 10)
	assert_eq(_card.get_suit_bonus(), 0)


func test_process_value_ignores_missing_room() -> void:
	Game.curr_room = null
	assert_eq(_card.process_value(10), 10)


func test_component_inherits_card_bonus() -> void:
	var comp := _add_block_comp(10)
	assert_eq(comp.process_value(10), 15)
	assert_eq(comp.get_processed_value(), 15)
	assert_eq(comp.generate_desc(), "Gain 15 BLOCK.")


func test_generic_value_uses_bonus() -> void:
	_add_block_comp(10)
	assert_eq(_card.get_generic_value(), 15)


func test_activation_applies_bonus() -> void:
	var comp := _add_block_comp(10)
	_source.stats.Block.maxValue = 100
	_source.stats.Block.value = 0
	comp.activate()
	assert_eq(_source.stats.Block.value, 15)


func test_koz_suit_change_emits_update_status() -> void:
	watch_signals(_card)
	Game.koz_suit_changed.emit(Const.SuitTypes.Hearts)
	assert_signal_emitted(_card, "update_status")


func test_description_tracks_current_suit() -> void:
	var comp := _add_block_comp(10)
	assert_eq(comp.generate_desc(), "Gain 15 BLOCK.")
	_room.koz_suit = Const.SuitTypes.Hearts
	assert_eq(comp.generate_desc(), "Gain 10 BLOCK.")

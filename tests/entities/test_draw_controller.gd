extends GutTest

## Tests for the DrawController resource and Entity draw integration.

const FIXTURES := preload("res://tests/entities/helpers/fixtures.gd")
const KNIGHT_DATA := preload("res://entities/player_classes/knight_class_data.tscn")
const MERCENARY_DATA := preload("res://entities/player_classes/mercenary_class_data.tscn")

var _controller : DrawController
var _entity : Entity
var _cards : Array[CardData]
var _original : Array[CardData]


func before_each() -> void:
	_controller = DrawController.new()
	_controller.draw_mode = DrawController.DrawMode.Sequential

	_cards = _make_cards([Const.SuitTypes.Spades, Const.SuitTypes.Clubs, \
		Const.SuitTypes.Diamonds, Const.SuitTypes.Clubs])
	_original = _cards.duplicate()

	_entity = Entity.new()
	add_child_autofree(_entity)
	var data := EntityData.new()
	data.draw_controller = _controller
	add_child_autofree(data)
	_entity.data = data
	_entity.cards_deck.assign(_cards)


func _make_cards(suits : Array) -> Array[CardData]:
	var result : Array[CardData] = []
	for suit in suits:
		var card := FIXTURES.card()
		card.suit = suit
		add_child_autofree(card)
		result.append(card)
	return result


func test_sequential_pick_returns_first_card_without_removing() -> void:
	assert_eq(_controller.pick(_cards), _cards[0])
	assert_eq(_cards.size(), 4)


func test_sequential_pop_preserves_remaining_order() -> void:
	var expected := _cards[0]
	assert_eq(_controller.pop(_cards), expected)
	assert_eq(_cards.size(), 3)
	assert_eq(_cards[0], _cards_original(1))
	assert_eq(_cards[1], _cards_original(2))


func test_suit_filter_takes_first_match_and_leaves_others() -> void:
	var allowed : Array[Const.SuitTypes] = [Const.SuitTypes.Clubs]
	assert_eq(_controller.pop(_cards, allowed), _cards_original(1))
	assert_eq(_cards.size(), 3)
	assert_eq(_cards[0], _cards_original(0))
	assert_eq(_cards[1], _cards_original(2))
	assert_eq(_cards[2], _cards_original(3))


func test_pick_respects_excluded() -> void:
	var excluded : Array[CardData] = [_cards[0]]
	assert_eq(_controller.pick(_cards, [], excluded), _cards[1])


func test_empty_candidates_return_null() -> void:
	var allowed : Array[Const.SuitTypes] = [Const.SuitTypes.Hearts]
	assert_null(_controller.pick(_cards, allowed))
	assert_null(_controller.pop(_cards, allowed))
	assert_eq(_cards.size(), 4)


func test_random_pick_returns_a_member_of_the_deck() -> void:
	_controller.draw_mode = DrawController.DrawMode.Random
	assert_true(_cards.has(_controller.pick(_cards)))


func test_entity_pop_action_deck_uses_controller() -> void:
	var allowed : Array[Const.SuitTypes] = [Const.SuitTypes.Clubs]
	assert_eq(_entity.pop_action_deck(allowed), _cards_original(1))
	assert_eq(_entity.cards_deck.size(), 3)
	assert_eq(_entity.cards_deck[0], _cards_original(0))


func test_entity_draw_actions_uses_deck_order() -> void:
	_entity.draw_actions(2)
	assert_eq(_entity.cards_hand.size(), 2)
	assert_eq(_entity.cards_hand[0], _cards_original(0))
	assert_eq(_entity.cards_hand[1], _cards_original(1))
	assert_eq(_entity.cards_deck.size(), 2)


func test_entity_get_actions_hand_respects_order_and_excluded() -> void:
	_entity.cards_hand.assign(_cards)
	var excluded : Array[CardData] = [_cards[0]]
	var picked := _entity.get_actions_hand(2, excluded)
	assert_eq(picked.size(), 2)
	assert_eq(picked[0], _cards[1])
	assert_eq(picked[1], _cards[2])


func test_class_scenes_author_expected_modes() -> void:
	var knight := KNIGHT_DATA.instantiate() as ClassData
	add_child_autofree(knight)
	assert_eq(knight.draw_controller.draw_mode, DrawController.DrawMode.Sequential)

	var mercenary := MERCENARY_DATA.instantiate() as ClassData
	add_child_autofree(mercenary)
	assert_eq(mercenary.draw_controller.draw_mode, DrawController.DrawMode.Random)


func _cards_original(idx : int) -> CardData:
	return _original[idx]

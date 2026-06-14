extends Node
class_name Entity

@onready var stats : StatBlock
@onready var data : EntityData

var cards_hand : Array[CardData]
var cards_deck : Array[CardData]
var status_effects : Array[StatusEffData]

signal hand_changed(cards_hand : Array[CardData])
signal card_activated(card_data : CardData)
signal status_effects_changed(status_effects)

func config(data_ : EntityData):
	data = data_
	data.config()
	stats = data.default_stats.duplicate(true)
	stats.Health.no_stat_val.connect(on_death)
	add_actions_deck(data.card_deck)

func _ready() -> void:
	Game.on_start_turn.connect(start_turn)
	start_turn()

func start_turn():
	stats.Tempo.reset()
	draw_hand()

#region Hand
func add_action_hand(action : Action):
	self.cards_hand.append(action)
	hand_changed.emit(cards_hand)

func add_actions_hand(actions : Array):
	for action in actions:
		self.cards_hand.append(action)
	hand_changed.emit(cards_hand)

func get_rand_actions_hand(num : int):
	var actions = []
	for i in range(num):
		var filtered_hand = self.cards_hand.filter(func(x): return !actions.has(x))
		if filtered_hand.size() > 0:
			actions.append(filtered_hand.pick_random())
	return actions

func play_rand_actions_hand(num : int):
	var actions = get_rand_actions_hand(num)
	actions.all(func(x): x.activate())
	hand_changed.emit(cards_hand)

func clear_hand():
	for i in range(cards_hand.size()):
		move_action_to_deck(cards_hand[0])
	hand_changed.emit(cards_hand)

func draw_hand(is_clear_hand : bool = true):
	if is_clear_hand: clear_hand()
	add_actions_hand(pop_rand_actions_deck(data.card_hand_size))

func draw_actions(num):
	add_actions_hand(pop_rand_actions_deck(num))

func replace_action_hand(action_to_replace, action_to_be_replaced):
	var cardIdx = self.cards_hand.find(action_to_be_replaced)
	if cardIdx == -1:
		return

	self.cards_hand.erase(cardIdx)
	self.cards_hand.insert(cardIdx, action_to_replace)
	hand_changed.emit(cards_hand)

func pop_next_actions_deck(num):
	var cards = []
	for i in range(num):
		var drawn_card = self.cards_deck[0]
		self.cards_deck.erase(drawn_card)
		cards.append(drawn_card)
	return cards

func move_actions_hand_deck(num):
		range(num).all(func(_x): move_action_to_deck(get_rand_action_deck()))

func move_action_to_deck(actionData : CardData, isActivation : bool = false):
	self.cards_hand.erase(actionData)
	self.cards_deck.append(actionData)

	if !isActivation:
		self.hand_changed.emit(cards_hand)
	else:
		self.card_activated.emit(actionData)

#endregion

#region Deck
func add_action_deck(action : CardData):
	action.activated.connect(func(): move_action_to_deck(action, true))
	self.cards_deck.append(action)
	%CardDatas.add_child(action)
	action.config_source(self)

func add_actions_deck(actions : Array):
	for action in actions:
		add_action_deck(action)

func get_rand_action_deck() -> CardData:
	if self.cards_deck.size() <= 0: return null
	return self.cards_deck.pick_random()

func get_rand_actions_deck(num):
	if self.cards_deck.size() <= 0: return []
	var cards = []
	for i in range(num):
		var drawn_card = get_rand_action_deck()
		if drawn_card == null:
			return cards
		cards.append(drawn_card)
	return cards

func pop_rand_action_deck() -> CardData:
	if self.cards_deck.size() <= 0: return null

	var drawn_card = self.cards_deck.pick_random()
	if drawn_card == null:
		return null
	self.cards_deck.erase(drawn_card)
	return drawn_card

func pop_rand_actions_deck(num):
	if self.cards_deck.size() <= 0: return []
	var cards = []
	for i in range(num):
		var drawn_card = pop_rand_action_deck()
		if drawn_card == null:
			return cards
		cards.append(drawn_card)
	return cards
#endregion

#region Status Eff
func add_status_effect(effect : StatusEffData):
	var stacked : bool = false
	for eff in self.status_effects:
		if eff.type == effect.type and eff.duration == effect.duration:
			eff.stacks += effect.stacks
			stacked = true

	if stacked or self.status_effects.size() <= 0:
		effect.config_source(self)
		self.status_effects.append(effect)
		%EffectDatas.add_child(effect)

	status_effects_changed.emit(status_effects)

func remove_status_effect(effect : StatusEffData):
	self.status_effects.erase(effect)

	if %EffectDatas.get_children().any(func(x): return x == effect):
		%EffectDatas.remove_child(effect)
	status_effects_changed.emit(status_effects)

func get_effects(type : Const.StatusEffects) -> Array[StatusEffData]:
	return status_effects.filter(func(x): return x.type == type)

func take_damage(dmg : int):
	dmg = process_damage_incoming(dmg)
	stats.take_damage(dmg)

func on_death():
	pass

func process_damage_outgoing(dmg : int) -> int:
	for eff in get_effects(Const.StatusEffects.STRENGTH):
		dmg += eff.stacks
	return dmg

func process_damage_incoming(dmg : int) -> int:
	for eff in get_effects(Const.StatusEffects.RESILIENCE):
		dmg -= eff.stacks
	return dmg

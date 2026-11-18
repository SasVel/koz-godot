extends Control

@export var player : Player
@onready var actions_container : Control = %ActionsContainer
@onready var actions_container_default_pos
@onready var tools_list_default_pos

## Offset of card containers on card pickup.
@export var pickup_offset = 80
@export var pickup_offset_duration = 0.15
@export var hidden_offset = 280
@export var hidden_offset_duration = 0.45

@export var phases_container : RadialContainer
@onready var placeholder_scn = preload("res://UI/placeholder.tscn")

@export var attack_phase_offset = 0.14
@export var defend_phase_offset = 0.63

enum CardDisplayModes {
	Active,
	Inactive,
	Hidden
}
@onready var curr_card_display_mode : CardDisplayModes :
	set(val):
		if curr_card_display_mode == val: return
		match val:
			CardDisplayModes.Active:
				switch_cards(true)
				player.check_state_card_datas()
			CardDisplayModes.Inactive:
				switch_cards(false)
			CardDisplayModes.Hidden:
				tween_hand_offset(false)
				switch_cards(false)
		tween_card_containers(val)

		curr_card_display_mode = val

func _ready() -> void:
	await player.ready
	Game.init()

	%PlayerBar.config(player.stats.Health, player.stats.Block)
	%TempoDisplay.config(\
	Const.ACCENT_COLOR,
	player.stats.Tempo)
	%AttackPhaseMarker.modulate = Const.ACCENT_COLOR
	%DefendPhaseMarker.modulate = Const.COMPLIMENTARY_COLOR
	Game.on_changed_phase.connect(tween_phase_change)
	Game.on_rooms_completed.connect(update_rooms_label)
	Game.on_rooms_completed.connect(func(_x): curr_card_display_mode = CardDisplayModes.Hidden)
	Game.on_new_room.connect(set_player_ui_state)
	phases_container.progress_offset = attack_phase_offset

	player.hand_changed.connect(update_hand)
	player.drawn_hand.connect(draw_hand)
	player.tools_changed.connect(update_tools)

	Game.on_start_turn_layer_1.connect(on_start_turn_layer_1)
	Game.on_start_turn_layer_2.connect(on_start_turn_layer_2)
	Game.on_end_player_turn.connect(on_end_player_turn)
	Game.on_is_playing_event.connect(on_is_playing_event)

	actions_container_default_pos = actions_container.position
	tools_list_default_pos = %ToolsList.position

func set_player_ui_state():
	%ActionsContainer.visible = Game.curr_room.is_combat
	%ToolsList.visible = Game.curr_room.is_combat
	%EndTurnBtn.visible = Game.curr_room.is_combat
	%PhasesContainer.visible = Game.curr_room.is_combat
	%TempoDisplay.visible = Game.curr_room.is_combat

	if Game.curr_room.is_combat:
		update_hand(player.cards_hand, true)
		update_tools(player.equipped_tools, true)
		update_rooms_label(Game.rooms_completed)
		update_turns_label(Game.turn_counter)

func draw_hand(cards_hand):
	await tween_hand_offset(false)
	update_hand(cards_hand)
	await get_tree().create_timer(0.5).timeout
	await tween_hand_offset(true)

func tween_hand_offset(isOpen : bool):
	%ActionsContainer.queue_sort()
	await %ActionsContainer.sort_children
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	if isOpen:
		tween.tween_property(%ActionsContainer, "progress_offset", 1.00, 0.8)
	else:
		tween.tween_property(%ActionsContainer, "progress_offset", 0.45, 0.8)
	await tween.finished

func update_hand(data : Array, clear : bool = false):
	var children = %ActionsContainer.get_children()
	if clear:
		for child in children:
			child.queue_free()
			await child.tree_exited
	if data.size() <= 0: return
	var card_objects = _get_card_objects()

	for info in data:
		if card_objects.any(func(x): return x.data == info): continue
		else:
			var card_inst = ObjManager.get_card_obj(info)
			card_inst.drag_started.connect(on_card_pickup)
			card_inst.drag_ended.connect(on_card_drop)
			%ActionsContainer.add_child(card_inst)
			%ActionsContainer.move_child(
				card_inst, _get_placeholders().size() + data.find(info))
	card_objects = _get_card_objects()
	for card in card_objects:
		if data.all(func(x): return x != card.data):
			card.queue_free()

	card_objects = _get_card_objects()
	var placeholders = _get_placeholders()
	var placeholder_needed_count = data.size() + 2
	var placeholder_diff = placeholder_needed_count - placeholders.size()
	if placeholder_diff > 0:
		for i in range(placeholder_diff):
			var placeholder_inst = placeholder_scn.instantiate()
			%ActionsContainer.add_child(placeholder_inst)
			%ActionsContainer.move_child(placeholder_inst, 0)
	elif placeholder_diff < 0:
		for i in range(-placeholder_diff):
			var placeholder_inst = placeholders.pop_back()
			%ActionsContainer.remove_child(placeholder_inst)
			placeholder_inst.queue_free()

	%ActionsContainer.refresh()

func _get_card_objects():
	return %ActionsContainer.get_children().filter(func(x): return x is CardObj)

func _get_placeholders():
	return %ActionsContainer.get_children().filter(func(x): return x is Placeholder)

func update_tools(data : Array, clear : bool = true):
	if clear:
		for child in %ToolsList.get_children():
			child.queue_free()

	_setup_tool(0, data[0])
	_setup_tool(1, data[1])

func _setup_tool(idx, tool):
	var card_inst = ObjManager.get_tool_obj(tool)
	if idx == 0:
		card_inst.size_flags_horizontal = SizeFlags.SIZE_EXPAND + SizeFlags.SIZE_SHRINK_BEGIN
	else:
		card_inst.size_flags_horizontal = SizeFlags.SIZE_EXPAND + SizeFlags.SIZE_SHRINK_END
	card_inst.drag_started.connect(on_card_pickup)
	card_inst.drag_ended.connect(on_card_drop)
	%ToolsList.add_child(card_inst)

func update_rooms_label(val : int):
	%RoomsLabel.text = "Rooms Completed: %s" % str(val)

func update_turns_label(val : int):
	%EndTurnBtn.text = "End Turn %s" % str(val)

func tween_phase_change(val : Game.Phases):
	%PhasesContainer.tooltip_text = get_phases_text(val)
	var tween = create_tween()\
		.set_ease(Tween.EASE_IN_OUT)\
		.set_trans(Tween.TRANS_CUBIC)
	if val == Game.Phases.ATTACK:
		tween.tween_property(%PhasesContainer, "progress_offset",
		attack_phase_offset, 0.5)
	else:
		tween.tween_property(%PhasesContainer, "progress_offset",
		defend_phase_offset, 0.5)

func get_phases_text(phase : Game.Phases) -> String:
	var attack_text = "+1 TEMPO."
	var defend_text = "Retain BLOCK."
	if phase == Game.Phases.ATTACK:
		return "This turn: %s\nNext turn: %s" % [attack_text, defend_text]
	else:
		return "This turn: %s\nNext turn: %s" % [defend_text, attack_text]


func _on_player_configured(_entity) -> void:
	%PlayerNameLabel.text = "%s %s" % [Game.player_name, player.data.entity_name]

func tween_card_containers(card_display_mode : CardDisplayModes):
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	match card_display_mode:
		CardDisplayModes.Active:
			tween.tween_property(actions_container, "position:y", actions_container_default_pos.y, pickup_offset_duration)
			tween.parallel().tween_property(%ToolsList, "position:y", tools_list_default_pos.y, pickup_offset_duration)
		CardDisplayModes.Inactive:
			tween.tween_property(actions_container, "position:y", actions_container_default_pos.y + pickup_offset, pickup_offset_duration)
			tween.parallel().tween_property(%ToolsList, "position:y", tools_list_default_pos.y + pickup_offset, pickup_offset_duration)
		CardDisplayModes.Hidden:
			tween.tween_property(actions_container, "position:y", actions_container_default_pos.y + hidden_offset, hidden_offset_duration)
			tween.parallel().tween_property(%ToolsList, "position:y", tools_list_default_pos.y + hidden_offset, hidden_offset_duration)

#region Signal Callables
func _on_player_card_activated(card_data: CardData) -> void:
	var children = actions_container.get_children()
	var control_removed : bool = false
	for child in children:
		if !control_removed and \
		child is not CardObj and \
		child is Control:
			child.queue_free()
			control_removed = true
			continue
		if child is CardObj and \
		child.data == card_data:
			child.queue_free()
			return

func on_card_pickup(_card):
	curr_card_display_mode = CardDisplayModes.Inactive

func on_card_drop(_card):
	curr_card_display_mode = CardDisplayModes.Active

func on_start_turn_layer_1():
	update_turns_label(Game.turn_counter)

func on_start_turn_layer_2():
	curr_card_display_mode = CardDisplayModes.Active

func on_end_player_turn():
	curr_card_display_mode = CardDisplayModes.Hidden

func on_is_playing_event(isOn : bool):
	if curr_card_display_mode == CardDisplayModes.Hidden: return
	curr_card_display_mode = CardDisplayModes.Inactive if isOn else CardDisplayModes.Active

func switch_cards(isOn : bool):
	for card in player.cards_hand: _switch_card(card, isOn)
	for tool in player.equipped_tools: _switch_card(tool, isOn)

func _switch_card(card, isOn : bool):
	card.isOn = isOn
	return card

#endregion

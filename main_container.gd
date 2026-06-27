extends Control

@export var player : Player
@onready var actions_container : Control = %ActionsContainer
@export var phases_container : RadialContainer
@onready var placeholder_scn = preload("res://UI/placeholder.tscn")

@export var attack_phase_offset = 0.14
@export var defend_phase_offset = 0.63

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
	phases_container.progress_offset = attack_phase_offset

	player.hand_changed.connect(update_hand)
	player.tools_changed.connect(update_tools)

	update_hand(player.cards_hand, true)
	update_tools(player.equipped_tools, true)
	update_rooms_label(Game.rooms_completed)
	update_turns_label(Game.turn_counter)
	Game.on_start_turn_layer_1.connect(func(): update_turns_label(Game.turn_counter))


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
			%ActionsContainer.add_child(card_inst)
	card_objects = _get_card_objects()
	for card in card_objects:
		if data.all(func(x): return x != card.data):
			card.queue_free()

	card_objects = _get_card_objects()
	var placeholders = _get_placeholders()
	var placeholder_needed_count = data.size() + 2
	if placeholders.size() == placeholder_needed_count: return
	if placeholders.size() < placeholder_needed_count:
		for i in range(placeholder_needed_count):
			var placeholder_inst = placeholder_scn.instantiate()
			%ActionsContainer.add_child(placeholder_inst)
			%ActionsContainer.move_child(placeholder_inst, 0)
	elif placeholders.size() > placeholder_needed_count:
		for i in range(placeholders.size() - placeholder_needed_count):
			placeholders.pop_back().queue_free()

func _get_card_objects():
	return %ActionsContainer.get_children().filter(func(x): return x is CardObj)

func _get_placeholders():
	return %ActionsContainer.get_children().filter(func(x): return x is Placeholder)

func update_tools(data : Array, clear : bool = true):
	if clear:
		for child in %ToolsList.get_children():
			child.queue_free()

	for info in data:
		var card_inst = ObjManager.get_tool_obj(info)
		%ToolsList.add_child(card_inst)

func update_rooms_label(val : int):
	%RoomsLabel.text = "Rooms Completed: %s" % str(val)

func update_turns_label(val : int):
	%TurnsLabel.text = "Turn: %s" % str(val)

func tween_phase_change(val : Game.Phases):
	var tween = create_tween()\
		.set_ease(Tween.EASE_IN_OUT)\
		.set_trans(Tween.TRANS_CUBIC)
	if val == Game.Phases.ATTACK:
		tween.tween_property(%PhasesContainer, "progress_offset",
		attack_phase_offset, 0.5)
	else:
		tween.tween_property(%PhasesContainer, "progress_offset",
		defend_phase_offset, 0.5)

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


func _on_player_configured() -> void:
	%PlayerNameLabel.text = "%s %s" % [Game.player_name, player.data.entity_name]

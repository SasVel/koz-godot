extends Control

@export var player : Player
@onready var actions_container : Control = %ActionsContainer

@export var attack_phase_offset = 0.14
@export var defend_phase_offset = 0.63

func _ready() -> void:
	await player.ready
	Game.init()

	%PlayerBar.config(player.stats.Health, player.stats.Block)
	%TempoDisplay.config(\
	Const.ACTION_COLOR,
	player.stats.Tempo)
	%AttackPhaseMarker.modulate = Const.ATTACK_COLOR
	%DefendPhaseMarker.modulate = Const.DEFEND_COLOR
	Game.on_changed_phase.connect(tween_phase_change)
	Game.on_rooms_completed.connect(update_rooms_label)
	%PhasesContainer.progress_offset = attack_phase_offset

	player.hand_changed.connect(update_hand)
	player.tools_changed.connect(update_tools)

	update_hand(player.cards_hand)
	update_tools(player.equipped_tools)
	update_rooms_label(Game.rooms_completed)

func update_hand(data : Array):
	for child in actions_container.get_children():
		child.queue_free()

	for i in range(data.size()):
		%ActionsContainer.add_child(Control.new())

	for info in data:
		var card_inst = ObjManager.get_card_obj(info)
		%ActionsContainer.add_child(card_inst)

func update_tools(data : Array):
	for child in %ToolsList.get_children():
		child.queue_free()

	for info in data:
		var card_inst = ObjManager.get_tool_obj(info)
		%ToolsList.add_child(card_inst)

func update_rooms_label(val : int):
	%RoomsLabel.text = "%s Rooms Completed" % str(val)

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

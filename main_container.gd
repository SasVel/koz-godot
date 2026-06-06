extends Control

@export var player : Player
@onready var actions_container : Control = %ActionsContainer

func _ready() -> void:
	await player.ready
	%PlayerBar.config(player.stats.Health, player.stats.Block)
	%TempoDisplay.config(\
	Const.ACTION_COLOR,
	player.stats.Tempo)

	player.hand_changed.connect(update_hand)
	update_hand(player.cards_hand)

func update_hand(data : Array):
	for child in actions_container.get_children():
		child.queue_free()

	for i in range(data.size()):
		%ActionsContainer.add_child(Control.new())

	for info in data:
		var card_inst = ObjManager.get_card_obj(info)
		%ActionsContainer.add_child(card_inst)

extends Node2D
class_name Room

@export var type : Const.RoomTypes

@onready var koz_suit : Const.SuitTypes = \
	randi_range(0, Const.SuitTypes.size() - 1) as Const.SuitTypes

@export var is_combat : bool = true
@export var dialogue : DialogueResource

signal completed

func _ready() -> void:
	get_parent().move_child.call_deferred(self, 3)

func check_completed():
	pass

func switch_transition(isOn : bool):
	if isOn:
		await try_activate_dialogue()

func try_activate_dialogue():
	if dialogue == null: return
	DialogueManager.show_dialogue_balloon(dialogue, "start")
	await DialogueManager.dialogue_ended

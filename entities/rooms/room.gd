extends Node2D
class_name Room

@export var type : Const.RoomTypes

@onready var koz_suit : Const.SuitTypes = \
	randi_range(0, Const.SuitTypes.size() - 1) as Const.SuitTypes :
	set(val):
		Game.koz_suit_changed.emit(val)
		koz_suit = val

@export var is_combat : bool = true
@export var dialogue : DialogueResource

@warning_ignore("unused_signal")
signal completed

func _ready() -> void:
	get_parent().move_child.call_deferred(self, 3)
	Game.on_new_room.connect(func(): Game.add_event(try_activate_dialogue))

func check_completed():
	pass

func try_activate_dialogue():
	if dialogue == null: return
	DialogueManager.show_dialogue_balloon(dialogue, "start")
	await DialogueManager.dialogue_ended

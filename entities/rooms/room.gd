extends Node2D
class_name Room

@export var type : Const.RoomTypes
@export var dialogue : DialogueResource

signal completed

func _ready() -> void:
	get_parent().move_child.call_deferred(self, 3)
	%Transition.factor = 1

func check_completed():
	pass

func switch_transition(isOn : bool):
	var tween = create_tween().set_ease(Tween.EASE_OUT)
	tween.tween_property(%Transition, "factor", 0 if isOn else 1, 2).from(1 if isOn else 0)
	await tween.finished

	if isOn:
		await try_activate_dialogue()

func try_activate_dialogue():
	if dialogue == null: return
	DialogueManager.show_dialogue_balloon(dialogue, "start")
	await DialogueManager.dialogue_ended

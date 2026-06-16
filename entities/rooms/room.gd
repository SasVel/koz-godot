extends Node2D
class_name Room

@export var type : Const.RoomTypes

signal completed

func _ready() -> void:
	get_parent().move_child(self, 2)
	%Transition.factor = 1

func check_completed():
	pass

func switch_transition(isOn : bool):
	Game.switch_input(false)
	var tween = create_tween().set_ease(Tween.EASE_OUT)
	tween.tween_property(%Transition, "factor", 0 if isOn else 1, 2).from(1 if isOn else 0)
	await tween.finished
	Game.switch_input(true)

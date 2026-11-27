extends Control
class_name MenuUI

## UI component scene, holding smaller components.

func _ready() -> void:
	set_focus()

func _input(event: InputEvent) -> void:
	if GamePopup.has_active_popup(): return
	if (event is InputEventJoypadButton or event is InputEventJoypadMotion)\
			and get_viewport().gui_get_focus_owner() == null:
		set_focus()

## To be overriden
func set_focus():
	pass

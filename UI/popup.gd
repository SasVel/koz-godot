extends MenuUI
class_name GamePopup

@export var is_closeable : bool = false

signal finished

## Only the frontmost popup keeps focus; menus behind it cannot take it.
static var active_popups : Array[GamePopup] = []

var _previous_focus : Control

func close() -> void:
	finished.emit()

func cancel() -> void:
	close()

static func has_active_popup() -> bool:
	return not active_popups.is_empty()

func _notification(what : int) -> void:
	match what:
		NOTIFICATION_READY:
			_previous_focus = get_viewport().gui_get_focus_owner()
			active_popups.append(self)
			get_viewport().gui_focus_changed.connect(_keep_focus_inside)
			## Deferred so controls built in _ready() already exist.
			call_deferred("set_focus")
		NOTIFICATION_EXIT_TREE:
			active_popups.erase(self)
			get_viewport().gui_focus_changed.disconnect(_keep_focus_inside)
			if is_instance_valid(_previous_focus) and _previous_focus.is_inside_tree():
				_previous_focus.grab_focus()

func _keep_focus_inside(control : Control) -> void:
	if control != null and is_ancestor_of(control):
		return
	if active_popups.back() == self and is_visible_in_tree():
		set_focus()

## To be overriden. Defaults to the first focusable child.
func set_focus() -> void:
	for child in find_children("*", "Control", true, false):
		var control := child as Control
		if control.is_visible_in_tree() and control.focus_mode != Control.FOCUS_NONE:
			control.grab_focus()
			return

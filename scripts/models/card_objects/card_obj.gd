extends DragObject
class_name CardObj

@export var focus_tween_speed = 0.2
@export var focus_scale = 1.2
var focus_card_pos_y = self.position.y - (self.size.y / 2)

func _on_focus_entered() -> void:
	self.z_index = 1
	move_on_focus(true)
	scale_on_focus(true)

func _on_focus_exited() -> void:
	self.z_index = 0
	move_on_focus(false)
	scale_on_focus(false)

func scale_on_focus(isOn : bool):
	var tween = create_tween()
	if isOn:
		tween.tween_property(self, "scale", Vector2(focus_scale, focus_scale), focus_tween_speed)
	else:
		tween.tween_property(self, "scale", Vector2(1, 1), focus_tween_speed)

func move_on_focus(isOn : bool):
	var tween = create_tween()
	if isOn:
		tween.tween_property(self, "position:y", focus_card_pos_y,
		 focus_tween_speed).from(0)
	else:
		tween.tween_property(self, "position:y", 0, focus_tween_speed)

func _on_mouse_entered() -> void:
	self.grab_focus()

func _on_mouse_exited() -> void:
	self.release_focus()

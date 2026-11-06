extends ColorRect
class_name FocusRect

func _ready() -> void:
	ObjManager.focus_rect = self
	self.material.set_shader_parameter("edge_color", Const.ACCENT_COLOR)
	unfocus()

func focus_control(control : Control):
	self.global_position = control.global_position
	self.visible = true

func unfocus():
	self.visible = false

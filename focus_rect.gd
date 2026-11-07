extends ColorRect
class_name FocusRect

@export var max_opacity : float = 0.8
@export var fade_speed : float = 0.15
var tween : Tween

func _ready() -> void:
	ObjManager.focus_rect = self
	self.material.set_shader_parameter("edge_color", Const.ACCENT_COLOR)
	unfocus()

func focus_control(control : Control):
	self.global_position = control.global_position
	tween_focus()

func tween_focus():
	self.visible = true
	tween = create_tween()
	tween.tween_property(self, "modulate:a", max_opacity, fade_speed)
	await tween.finished

func unfocus():
	tween = create_tween()
	tween.tween_property(self, "modulate:a", 0, fade_speed)
	await tween.finished
	self.visible = false

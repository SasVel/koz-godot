extends TextureButton

@export var outline_rect : TextureRect

func _ready() -> void:
	self.modulate = Const.ACCENT_COLOR
	await get_tree().process_frame
	config_outline()
	outline_rect.visible = false

func config_outline():
	var color = Const.ACCENT_COLOR
	color.a = 0.6
	outline_rect.material.set_shader_parameter("custom_color", color)

func _on_focus_entered() -> void:
	outline_rect.visible = true

func _on_focus_exited() -> void:
	outline_rect.visible = false

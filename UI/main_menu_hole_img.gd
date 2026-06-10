extends TextureRect

func _ready() -> void:
	Obj.tween_shader_parameter(self, "size", 0.4, 0.445, 4, true)

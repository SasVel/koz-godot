extends TextureRect

func _ready() -> void:
	self.modulate = Const.ACCENT_COLOR
	var transparent_fire_color = Const.ACCENT_COLOR
	transparent_fire_color.a = 0.4
	%InnerCircle.modulate = transparent_fire_color
	%OuterCircle.modulate = transparent_fire_color.darkened(0.2)
	self.texture.region.position.x = 129 * randi_range(0, 2)

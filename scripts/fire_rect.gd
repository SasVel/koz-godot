extends TextureRect

func _ready() -> void:
	self.modulate = Const.FIRE_COLOR
	self.texture.region.position.x = 129 * randi_range(0, 2)

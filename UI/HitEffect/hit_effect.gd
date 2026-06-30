extends TextureRect
class_name HitEffect

@export var fade_out_duration : float = 0.5

func _ready() -> void:
	self.scale = Vector2(0.5, 0.5)
	self.rotation_degrees = randf_range(0, 360)
	self.modulate.a = 1
	self.visible = true

	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SPRING)
	tween.tween_property(self, "scale", Vector2(1,1), 0.2)

	tween.tween_property(self, "modulate:a", 0, fade_out_duration)
	tween.parallel().tween_property(self, "scale", Vector2(0.9, 0.9), fade_out_duration)
	tween.parallel().tween_property(self, "rotation_degrees", self.rotation_degrees + 8, fade_out_duration)
	await tween.finished
	self.queue_free()

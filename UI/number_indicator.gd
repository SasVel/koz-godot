extends Label
class_name NumberIndicator

@export var tween_fade_time : float = 0.5
@export var tween_scale : float = 1.2
@export var tween_pos_offset : int = 15
@export var tween_rot_deg : int = 45

func config(num : int, pos : Vector2, color : Color):
	self.global_position = pos
	self.text = str(num)
	self.label_settings.font_color = color

func _ready() -> void:
	tween_animate()

func tween_animate():
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_parallel()
	tween.tween_property(self, "modulate:a", 1, tween_fade_time * 0.4).from(0.5)
	tween.tween_property(self, "scale", Vector2(tween_scale, tween_scale), tween_fade_time * 0.6).from(Vector2(0.5, 0.5))
	tween.tween_property(self, "position", Vector2(position.x + randf_range(-tween_pos_offset, tween_pos_offset), position.y - tween_pos_offset + 35), tween_fade_time * 0.6)
	tween.tween_property(self, "rotation", deg_to_rad(randi_range(-tween_rot_deg, tween_rot_deg)), tween_fade_time * 0.6)
	await tween.finished
	
	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 0, tween_fade_time * 0.4)
	await tween.finished
	self.queue_free()

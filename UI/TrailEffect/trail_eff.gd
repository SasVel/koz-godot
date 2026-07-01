extends Path2D
class_name TrailEffect

@export var duration : float = 0.5

signal dest_reached

func config(color : Color, start : Vector2, dest : Vector2):
	self.curve.set_point_position(0, start)
	self.curve.set_point_position(2, dest)
	self.curve.set_point_position(1, offset_midpoint_right(start,dest, 5))
	var gradient = (%Particle.texture as GradientTexture2D).gradient
	gradient.set_color(0, color)
	var alpha_color = gradient.get_color(1)
	gradient.set_color(1, Color(color.r, color.g, color.b, alpha_color.a))

func offset_midpoint_right(P1: Vector2, P2: Vector2, s: float) -> Vector2:
	var m := (P1 + P2) * 0.5

	var dx := P2.x - P1.x
	var dy := P2.y - P1.y
	var L := Vector2(dx, dy).length()

	if L == 0.0:
		push_error("P1 and P2 are the same point; direction is undefined.")
		return P1

	# Unit perpendicular pointing "right" of P1 -> P2 (standard XY).
	var nx := dy / L
	var ny := -dx / L

	return Vector2(m.x + s * nx, m.y + s * ny)

func play():
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(%PathFollow, "progress_ratio", 1, duration).from(0)
	tween.parallel().tween_property(self, "modulate:a", 1, duration * 0.3).from(0)
	await tween.finished
	dest_reached.emit()
	self.queue_free()

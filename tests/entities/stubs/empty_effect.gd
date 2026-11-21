extends HitEffect


# Keep the HitEffect type so Enemy.take_damage()'s typed local still works,
# but skip the fade animation/tween.
func _ready() -> void:
	pass

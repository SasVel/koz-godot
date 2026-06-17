extends Control
class_name MiniDisplay

func update(num):
	%NumLabel.text = str(snapped(num, 1))

func tween_activate(is_for_deletion : bool = true):
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.2)
	tween.tween_property(self, "scale", Vector2.ZERO if is_for_deletion else Vector2.ONE, 0.3)
	await tween.finished

extends Control

var anim_speed : float = 5

func _ready() -> void:
	Game.on_start_turn.connect(play_turn_announcement)
	%TurnRect.scale.y = 0
	%TurnLabel.scale = Vector2.ZERO

func play_turn_announcement():
	%TurnLabel.text = "Turn %s" % str(Game.turn_counter)
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(%TurnRect, "scale:y", 1.2, anim_speed * 0.3)
	tween.parallel().tween_property(%TurnRect, "modulate:a", 1, anim_speed * 0.3).from(0)
	tween.parallel().tween_property(%TurnLabel, "modulate:a", 1, anim_speed * 0.3).from(0)
	tween.parallel().tween_property(%TurnLabel, "scale", Vector2(1.2, 1.2), anim_speed * 0.3)

	# --- Pause ---

	tween.tween_property(%TurnLabel, "modulate:a", 0, anim_speed * 0.2)\
		.set_delay(anim_speed * 0.5)
	tween.parallel().tween_property(%TurnLabel, "scale", Vector2.ZERO, anim_speed * 0.2)
	tween.parallel().tween_property(%TurnRect, "scale:y", 0, anim_speed * 0.2)
	tween.parallel().tween_property(%TurnRect, "modulate:a", 0, anim_speed * 0.3)

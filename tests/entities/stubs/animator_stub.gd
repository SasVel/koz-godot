extends Node


func config(_settings: IdleAnimSettings = null) -> void:
	pass


# Coroutine so `await %HitAnimator.play()` works without real tweens.
func play() -> void:
	await get_tree().process_frame


func pause() -> void:
	pass


func stop() -> void:
	pass

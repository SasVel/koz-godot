extends Room


# Room._ready() assumes it is inside the real main scene and connects dialogue
# events. Tests only need the completed signal and a queued event so
# Game.set_room()'s `await event_queue_empty` can resolve.
func _ready() -> void:
	Game.add_event(_noop)


func _noop() -> void:
	pass

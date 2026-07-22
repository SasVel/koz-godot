extends DialogueRoom

func _ready() -> void:
	super()
	%PoolParticles.modulate = Const.ACCENT_COLOR
	%PoolCircle.modulate = Const.ACCENT_COLOR
	%PoolCircle.modulate.a = 0.8

func _response_selected(response : DialogueResponse):
	if response.tags.is_empty(): return
	for tag in response.tags:
		if tag == "heal":
			Game.player.stats.Health.add_percentage_to_value(0.3)
			Game.next_room()
		elif tag == "next_room":
			Game.next_room()

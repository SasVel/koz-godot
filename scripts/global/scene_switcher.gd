extends Control

func switch_to_scene(scene : PackedScene):
	await switch_transition(false)
	get_tree().change_scene_to_packed(scene)
	await switch_transition(true)

func fake_switch(duration : float):
	await switch_transition(false)
	await get_tree().create_timer(duration).timeout
	await switch_transition(true)

func switch_transition(isOn : bool):
	var tween = create_tween().set_ease(Tween.EASE_OUT)
	tween.tween_property(%Transition, "factor", 0 if isOn else 1, 2).from(1 if isOn else 0)
	await tween.finished

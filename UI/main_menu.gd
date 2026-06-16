extends Control

@export var main_scn : PackedScene
@export var credits_scn : PackedScene

func _ready() -> void:
	%Birb.modulate = Const.DEFEND_COLOR
	%Rock.modulate = Const.ACTION_COLOR
	%HoleImage.material.set_shader_parameter("modulate_color", Const.BACKGROUND_COLOR)
	switch_transition(true)

func _on_new_game_btn_pressed() -> void:
	await switch_transition(false)
	get_tree().change_scene_to_packed(main_scn)

func _on_credits_btn_pressed() -> void:
	get_tree().change_scene_to_packed(credits_scn)

func switch_transition(isOn : bool):
	var tween = create_tween().set_ease(Tween.EASE_OUT)
	tween.tween_property(%Transition, "factor", 0 if isOn else 1, 2).from(1 if isOn else 0)
	await tween.finished

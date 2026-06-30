extends Control

@export var main_scn : PackedScene
@export var credits_scn : PackedScene

func _ready() -> void:
	load_colors_from_palette()
	Const.palette_changed.connect(load_colors_from_palette)
	switch_transition(true)

func _on_new_game_btn_pressed() -> void:
	var name_popup = UI.get_popup_inst(UI.Popups.NAME)
	self.add_child(name_popup)
	await name_popup.finished
	name_popup.queue_free()

	var class_selection_popup = UI.get_popup_inst(UI.Popups.CLASS_SELECTION)
	self.add_child(class_selection_popup)
	await class_selection_popup.finished
	await switch_transition(false)
	get_tree().change_scene_to_packed(main_scn)

func _on_credits_btn_pressed() -> void:
	get_tree().change_scene_to_packed(credits_scn)

func switch_transition(isOn : bool):
	var tween = create_tween().set_ease(Tween.EASE_OUT)
	tween.tween_property(%Transition, "factor", 0 if isOn else 1, 2).from(1 if isOn else 0)
	await tween.finished

func set_theme_colors():
	var btn_stylebox : StyleBoxTexture
	# Normal stylebox edit
	btn_stylebox = theme.get_stylebox("normal", "Button")
	btn_stylebox.modulate_color = Const.BACKGROUND_LIGHTER_COLOR
	theme.set_stylebox("normal", "Button", btn_stylebox)

	# Pressed stylebox edit
	btn_stylebox = theme.get_stylebox("pressed", "Button")
	btn_stylebox.modulate_color = Const.BACKGROUND_LIGHTER_COLOR
	theme.set_stylebox("pressed", "Button", btn_stylebox)

	# Disabled stylebox edit
	btn_stylebox = theme.get_stylebox("disabled", "Button")
	btn_stylebox.modulate_color = Const.BACKGROUND_DARKER_COLOR
	theme.set_stylebox("disabled", "Button", btn_stylebox)

	# Panel container texture color
	var panel_container_stylebox = theme.get_stylebox("panel", "PanelContainer")
	panel_container_stylebox.modulate_color = Const.BACKGROUND_DARKER_COLOR
	theme.set_stylebox("panel", "PanelContainer", panel_container_stylebox)

func load_colors_from_palette():
	set_theme_colors()
	%Birb.modulate = Const.ACCENT_COLOR
	%Rock.modulate = Const.PRIMARY_COLOR
	%HoleImage.material.set_shader_parameter("modulate_color", Const.BACKGROUND_LIGHTER_COLOR)
	%Background.self_modulate = Const.BACKGROUND_COLOR

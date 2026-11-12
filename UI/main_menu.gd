extends Control

@export var main_scn : PackedScene
@export var credits_scn : PackedScene

func _ready() -> void:
	SFX.play_music(SFX.Music.Chill, true)
	load_colors_from_palette()
	Const.palette_changed.connect(load_colors_from_palette)

func _on_new_game_btn_pressed() -> void:
	var name_popup = UI.get_popup_inst(UI.Popups.NAME)
	self.add_child(name_popup)
	await name_popup.finished
	name_popup.queue_free()

	var class_selection_popup = UI.get_popup_inst(UI.Popups.CLASS_SELECTION)
	self.add_child(class_selection_popup)
	await class_selection_popup.finished
	SceneSwitcher.switch_to_scene(main_scn)

func _on_credits_btn_pressed() -> void:
	SceneSwitcher.switch_to_scene(credits_scn)

func load_colors_from_palette():
	UIHelper.set_theme_colors(self)
	%Birb.modulate = Const.ACCENT_COLOR
	%Rock.modulate = Const.PRIMARY_COLOR
	%HoleImage.material.set_shader_parameter("modulate_color", Const.BACKGROUND_LIGHTER_COLOR)
	%Background.self_modulate = Const.BACKGROUND_COLOR

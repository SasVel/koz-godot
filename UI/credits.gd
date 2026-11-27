extends MenuUI

@onready var main_menu_scn : PackedScene = load("res://UI/main_menu.tscn")

func _ready() -> void:
	%Background.self_modulate = Const.BACKGROUND_DARKER_COLOR

func _on_back_btn_pressed() -> void:
	SceneSwitcher.switch_to_scene(main_menu_scn)

func set_focus():
	%BackBtn.grab_focus()

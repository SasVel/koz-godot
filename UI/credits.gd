extends Control

@onready var main_menu_scn : PackedScene = load("res://UI/main_menu.tscn")

func _on_back_btn_pressed() -> void:
	SceneSwitcher.switch_to_scene(main_menu_scn)

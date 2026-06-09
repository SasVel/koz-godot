extends Control

@onready var main_menu_scn : PackedScene = load("res://UI/main_menu.tscn")

func _on_back_btn_pressed() -> void:
	get_tree().change_scene_to_packed(main_menu_scn)

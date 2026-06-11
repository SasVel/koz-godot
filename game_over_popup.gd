extends Control
class_name GameOverPopup

@onready var main_menu_scn : PackedScene = load("res://UI/main_menu.tscn")

func _ready() -> void:
	Game.switch_input(false)
	get_tree().paused = true
	%ScoreLabel.text = "Room Score: %s" % Game.rooms_completed

func _on_restart_btn_pressed() -> void:
	Game.restart()

func _on_main_menu_btn_pressed() -> void:
	get_tree().change_scene_to_packed(main_menu_scn)

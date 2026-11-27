extends GamePopup
class_name GameOverPopup

@onready var main_menu_scn : PackedScene = load("res://UI/main_menu.tscn")

func _ready() -> void:
	get_tree().paused = true
	%ScoreLabel.text = "Room Score: %s" % Game.rooms_completed

func config(is_win : bool):
	if is_win:
		%GameOverLabel.text = "You Won! :0"
	else:
		%GameOverLabel.text = "Game Over ;-;"
	return self

func _on_restart_btn_pressed() -> void:
	Game.restart()
	close()

func _on_main_menu_btn_pressed() -> void:
	SceneSwitcher.switch_to_scene(main_menu_scn)
	close()

func close():
	super()
	self.queue_free()

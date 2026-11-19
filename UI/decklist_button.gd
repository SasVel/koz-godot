extends TextureButton

func _ready() -> void:
	get_tree().paused = true

func _exit_tree() -> void:
	get_tree().paused = false

func _on_pressed() -> void:
	UI.show_screen(UI.Popups.DECKLIST)

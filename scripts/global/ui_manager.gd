extends Node

@export var popup_scenes : Dictionary[Popups, PackedScene]

enum Popups {
	LOOT,
	GAME_OVER,
	CLASS_SELECTION,
	NAME,
}

func get_popup_inst(type : Popups):
	return popup_scenes[type].instantiate()

func show_game_over_screen(is_win : bool):
	var screen = get_popup_inst(UI.Popups.GAME_OVER).config(is_win)
	Game.popupsContainer.add_child(screen)

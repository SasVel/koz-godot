extends Node

@export var popup_scenes : Dictionary[Popups, PackedScene]
var is_paused : bool = false

enum Popups {
	LOOT,
	GAME_OVER,
	CLASS_SELECTION,
	NAME,
	PAUSE,
	DECKLIST
}

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and !is_paused and Game.in_game:
		var active_popups = Game.popupsContainer.get_children()
		if active_popups.any(func(x): return x.is_closeable):
			active_popups\
				.filter(func(x): return x.is_closeable)\
				.map(func(x): x.close())
		else:
			is_paused = true
			show_screen(Popups.PAUSE)
	else:
		is_paused = false

func get_popup_inst(type : Popups):
	return popup_scenes[type].instantiate()

func show_game_over_screen(is_win : bool):
	var screen = get_popup_inst(Popups.GAME_OVER).config(is_win)
	Game.popupsContainer.add_child(screen)

func show_screen(type : Popups) -> Control:
	var screen = get_popup_inst(type)
	Game.popupsContainer.add_child(screen)
	return screen

extends Node

@export var popup_scenes : Dictionary[Popups, PackedScene]

enum Popups {
	LOOT,
	GAME_OVER
}

func get_popup_inst(type : Popups):
	return popup_scenes[type].instantiate()

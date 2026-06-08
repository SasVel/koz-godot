extends Node

@export var popup_scenes : Dictionary[Popups, PackedScene]

enum Popups {
	LOOT
}

func get_popup_inst(type : Popups):
	return popup_scenes[type].instantiate()

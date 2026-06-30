extends EntityData
class_name ClassData

@export var player_class : Const.PlayerClasses

@export_category("Pick tool type from the first array. Then choose starting
tools. One of each category up to 2 will be picked randomly.")
@export var tool_types : Array[Const.CardTypes]
@export var starting_weapons : Array[Const.Weapons]
@export var starting_shields : Array[Const.Shields]
@onready var starting_tools : Array[ToolData] = []

func config():
	super()
	load_tools()

func load_tools():
	for type in tool_types:
		match type:
			Const.CardTypes.WEAPON:
				starting_tools.append(\
					ObjManager.weapons_dict[starting_weapons.pick_random()].instantiate())
			Const.CardTypes.SHIELD:
				starting_tools.append(\
					ObjManager.shields_dict[starting_shields.pick_random()].instantiate())

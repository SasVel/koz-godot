extends EntityData
class_name ClassData

@export var player_class : Const.PlayerClasses
@export var suit : Const.SuitTypes

@export_category("Pick tool type from the first array. Then choose starting
tools. One of each category up to 2 will be picked randomly.")
@export var tool_types : Array[Const.CardTypes]
@export var starting_weapons : Array[Const.Weapons]
@export var starting_shields : Array[Const.Shields]

## Output array.
@onready var starting_tools : Array[ToolData] = []

func config():
	super()
	load_tools()

func load_tools(all_tools : bool = false):
	for type in tool_types:
		match type:
			Const.CardTypes.WEAPON:
				if !all_tools:
					starting_tools.append(\
						ObjManager.weapons_dict[starting_weapons.pick_random()].instantiate())
				else:
					for tool in starting_weapons:
						starting_tools.append(ObjManager.weapons_dict[tool].instantiate())
			Const.CardTypes.SHIELD:
				if !all_tools:
					starting_tools.append(\
						ObjManager.shields_dict[starting_shields.pick_random()].instantiate())
				else:
					for tool in starting_shields:
						starting_tools.append(ObjManager.shields_dict[tool].instantiate())

func get_tools(type : Const.CardTypes) -> Array[ToolData]:
	var tools_datas : Array[ToolData]
	match type:
		Const.CardTypes.WEAPON:
			for weapon in starting_weapons:
				tools_datas.append(ObjManager.weapons_dict[weapon].instantiate())
		Const.CardTypes.SHIELD:
			for shield in starting_shields:
				tools_datas.append(ObjManager.shields_dict[shield].instantiate())
	return tools_datas

func get_possible_tools_for_hand(hand_idx : int):
	var type = tool_types[hand_idx]
	return get_tools(type)
	

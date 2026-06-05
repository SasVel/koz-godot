extends Node

var path_to_palette : String = "res://data"
var path_to_palette_user : String = "user://data"
var palette_name = "palette.json"

## Enums 
enum CardTypes {
	GENERIC,
	ACTION,
	WEAPON,
	SHIELD,
}

enum Generic {
	ATTACK,  
	DEFEND,  
}

enum Actions {
	RIPOSTE, 
	LANGORT, 
	SURPRISE_SAND, 
	FEINT, 
	END_THEM_RIGHTLY, 
	PARRY, 
	PANIC, 
	ALBERT, 
}

enum Weapons {
	HALBERD, 
	SWORD, 
	MESSAR, 
	BASTARD_SWORD, 
	DAGGER, 
	MACE, 
}

enum Shields {
	SHIELD, 
	BUCKLER, 
}

enum StatusEffects {
	ADD_DMG, 
	REM_DMG, 
	ADD_BLOCK, 
	REM_BLOCK, 
	CHANGE_PHASE_ATK, 
	CHANGE_PHASE_DEF, 
	STUN, 
}

enum Enemies {
	SLIME, 
	SKELLY, 
	SHROOM, 
	GOBLIN, 
}

enum UnitTrackingVars {
	DAMAGE_DEALT, 
	DAMAGE_TAKEN, 
	BLOCK_GAINED, 
	TEMPO_GAINED, 
	STUN_APPLIED, 
}
enum StatTypes {
	Health,
	Block,
	Tempo,
	Damage,
}

var colors_obj

var BACKGROUND_COLOR: Color 
var ACTION_COLOR: Color
var TOOL_COLOR: Color

var ATTACK_COLOR: Color
var DEFEND_COLOR: Color
var CARD_BACK_COLOR: Color
var FIRE_COLOR: Color
var POSITIVE_COLOR: Color
var NEGATIVE_COLOR: Color

func _ready() -> void:
	load_colors_obj()

	BACKGROUND_COLOR = load_color(colors_obj["BACKGROUND_COLOR"])
	ACTION_COLOR= load_color(colors_obj["ACTION_COLOR"])
	TOOL_COLOR = load_color(colors_obj["TOOL_COLOR"])

	ATTACK_COLOR= load_color(colors_obj["ATTACK_COLOR"]) 
	DEFEND_COLOR= load_color(colors_obj["DEFEND_COLOR"])
	CARD_BACK_COLOR= load_color(colors_obj["CARD_BACK_COLOR"])
	FIRE_COLOR= load_color(colors_obj["FIRE_COLOR"])
	POSITIVE_COLOR= load_color(colors_obj["POSITIVE_COLOR"])
	NEGATIVE_COLOR= load_color(colors_obj["NEGATIVE_COLOR"])

func load_colors_obj() -> bool:
	var file
	if !check_palette_existing():
		DirAccess.make_dir_recursive_absolute(path_to_palette_user)
		DirAccess.make_dir_recursive_absolute(path_to_palette)
		var source_dir = DirAccess.open(path_to_palette)
		file = source_dir.get_files().get(0)
		source_dir.copy(path_to_palette + "/" + file,
		path_to_palette_user + "/" + file)

	file = FileAccess.open(path_to_palette_user + "/" + "palette.json",
	 FileAccess.READ)
	var json_text = file.get_as_text()
	var json = JSON.new()
	var error = json.parse(json_text)
	if error == OK:
		colors_obj = json.data
	else:
		push_error("colors JSON file did not load correctly.")
	return error == OK

func check_palette_existing() -> bool:
	return FileAccess.file_exists("usr://data/palette.json")

func load_color(color_info) -> Color:
	var color : Color
	if color_info is Array:
		color = Color.from_rgba8(color_info[0], color_info[1], color_info[2]) 
		if color_info.size() > 3:
			color.a = color_info[3]
	elif color_info is String:
		color = NamedColorDict.colors[color_info]

	return color

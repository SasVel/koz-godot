extends Node

var path_to_palette : String = "res://data"
var path_to_palette_user : String = "user://data"
var palette_name = "palette.json"
var themes : Dictionary[String, Dictionary]
var selected_theme : Array

## Enums
enum CardTypes {
	ACTION,
	WEAPON,
	SHIELD,
}

enum Actions {
	RIPOSTE = 0,
	LANGORT = 1,
	SURPRISE_SAND = 2,
	FEINT = 3,
	END_THEM_RIGHTLY = 4,
	PARRY = 5,
	PANIC = 6,
	ALBERT = 7,
	SLASH = 8,
	DEFEND = 9,
	SMASH = 10,
}

enum Weapons {
	HALBERD,
	SWORD,
	MESSER,
	BASTARD_SWORD,
	DAGGER,
	MACE,
}

enum Shields {
	SHIELD,
	BUCKLER,
}

enum StatusEffects {
	STRENGTH,
	RESILIENCE,
	CHANGE_PHASE_ATK,
	CHANGE_PHASE_DEF,
	STUN,
	WEAKNESS,
	FRAIL,
	POISON,
	CONSTRICT
}

enum Enemies {
	SLIME,
	SKELLY,
	SHROOM,
	GOBLIN,
	TREEANT,
}

enum PlayerClasses {
	KNIGHT,
	MERCENARY,
	BANDIT,
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

enum RoomTypes {
	Battle,
}


# Colors
var PRIMARY_COLOR: Color
var SECONDARY_COLOR: Color
var ACCENT_COLOR: Color
var COMPLIMENTARY_COLOR : Color
var BACKGROUND_COLOR: Color
var NEGATIVE_COLOR: Color

# Variations
var BACKGROUND_LIGHTER_COLOR : Color
var BACKGROUND_DARKER_COLOR : Color
var PRIMARY_HUE_SHIFT_UP_COLOR : Color
var PRIMARY_HUE_SHIFT_DOWN_COLOR : Color

signal palette_changed

func _ready() -> void:
	load_palettes()
	load_palette(0)

func load_palettes():
	var file
	if !check_palette_existing():
		DirAccess.make_dir_recursive_absolute(path_to_palette_user)
		DirAccess.make_dir_recursive_absolute(path_to_palette)
		var source_dir = DirAccess.open(path_to_palette)
		file = source_dir.get_files().get(0)
		source_dir.copy(path_to_palette + "/" + file,
		path_to_palette_user + "/" + file)
	var dir = DirAccess.open(path_to_palette)
	if dir:
		dir.list_dir_begin()
		var fileNames = dir.get_files()
		for fileName in fileNames:
			fileName = fileName.replace(".remap", "")
			file = ResourceLoader.load("/".join([path_to_palette, fileName]))
			themes[fileName.replace(".json", "")] = file.data

func load_palette(idx : int):
	var key = themes.keys()[idx]
	selected_theme = [key, themes[themes.keys()[idx]]]
	map_colors()
	palette_changed.emit()

func map_colors():
	var colors_obj : Dictionary = selected_theme[1]
	# Colors
	BACKGROUND_COLOR = load_color(colors_obj["BACKGROUND_COLOR"])
	PRIMARY_COLOR = load_color(colors_obj["PRIMARY_COLOR"])
	SECONDARY_COLOR = load_color(colors_obj["SECONDARY_COLOR"])
	ACCENT_COLOR = load_color(colors_obj["ACCENT_COLOR"])
	COMPLIMENTARY_COLOR = load_color(colors_obj["COMPLIMENTARY_COLOR"])
	NEGATIVE_COLOR= load_color(colors_obj["NEGATIVE_COLOR"])

	# Variations
	BACKGROUND_LIGHTER_COLOR = BACKGROUND_COLOR.lightened(0.2)
	BACKGROUND_DARKER_COLOR = BACKGROUND_COLOR.darkened(0.2)

	var primary_hue_shift_up = rgb_to_hsv(PRIMARY_COLOR)
	primary_hue_shift_up[0] += 0.02
	PRIMARY_HUE_SHIFT_UP_COLOR = Color.from_hsv(primary_hue_shift_up[0], primary_hue_shift_up[1], primary_hue_shift_up[2])

	var primary_hue_shift_down = rgb_to_hsv(PRIMARY_COLOR)
	primary_hue_shift_down[0] -= 0.01
	PRIMARY_HUE_SHIFT_DOWN_COLOR = Color.from_hsv(primary_hue_shift_down[0], primary_hue_shift_down[1], primary_hue_shift_down[2])

func check_palette_existing() -> bool:
	return FileAccess.file_exists("usr://data/palette_default.json")

func load_color(color_info) -> Color:
	var color : Color
	if color_info is Array:
		color = Color.from_rgba8(color_info[0], color_info[1], color_info[2])
		if color_info.size() > 3:
			color.a = color_info[3]
	elif color_info is String:
		if color_info[0] == "#":
			color = Color.html(color_info.replace(" ", ""))
		else:
			color = Color(color_info)

	return color

func rgb_to_hsv(c: Color) -> Vector3:
	# Input: Color with r,g,b in 0..1
	# Output: Vector3(h_degrees, s, v) where h in 0..360, s and v in 0..1
	var r = c.r
	var g = c.g
	var b = c.b
	var mx = max(r, max(g, b))
	var mn = min(r, min(g, b))
	var v = mx
	var d = mx - mn
	var s = 0.0
	var h = 0.0

	if mx > 0.0:
		s = d / mx
	else:
		s = 0.0

	if d > 0.0:
		if mx == r:
			h = (g - b) / d
			if h < 0.0:
				h += 6.0
		elif mx == g:
			h = (b - r) / d + 2.0
		else:
			h = (r - g) / d + 4.0
		h *= 60.0
	else:
		h = 0.0

	return Vector3(h, s, v)

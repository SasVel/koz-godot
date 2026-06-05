extends Node

@export var actions_dict : Dictionary[Const.Actions, PackedScene]
@export var weapons_dict : Dictionary[Const.Weapons, PackedScene]
@export var shields_dict : Dictionary[Const.Shields, PackedScene]
@export var enemies_dict : Dictionary[Const.Enemies, PackedScene]

@export var card_obj : PackedScene
@export var sprites_256_atlas : AtlasTexture

func get_rand_action_data(dict = actions_dict) -> CardData:
	return dict[randi_range(0, Const.Actions.size() - 1)].instantiate()

func get_rand_actions_datas(size, is_unique = false) -> Array[CardData]:
	var actions_dict_copy = actions_dict.duplicate()
	var arr : Array[CardData] = []
	for i in range(size):
		var data = get_rand_action_data(actions_dict_copy)
		if is_unique:
			actions_dict_copy.erase(data)
		arr.append(data)

	return arr

func get_rand_weapon_data() -> ToolData:
	return weapons_dict[randi_range(0, Const.Weapons.size() - 1)].instantiate()

func get_rand_shield_data() -> ToolData:
	return shields_dict[randi_range(0, Const.Shields.size() - 1)].instantiate()

func get_rand_enemy_data() -> Enemy:
	return enemies_dict[randi_range(0, Const.Enemies.size() - 1)].instantiate()

func get_rand_action_obj() -> CardObj:
	return card_obj.instantiate().config(get_rand_action_data())

func get_rand_weapon_obj() -> CardObj:
	return card_obj.instantiate().config(get_rand_weapon_data())

func get_rand_shield_obj() -> CardObj:
	return card_obj.instantiate().config(get_rand_shield_data())

func get_card_obj(data : CardData) -> CardObj:
	return card_obj.instantiate().config(data)

func get_weapon_sprite(type : Const.Weapons) -> AtlasTexture:
	var image = sprites_256_atlas.duplicate()
	image.region = Rect2(256 * type, 256, 0, 256)
	return image

func get_action_sprite(type : Const.Actions) -> AtlasTexture:
	var image = sprites_256_atlas.duplicate()
	image.region = Rect2(256 * type, 256, 256, 256)
	return image

func get_shield_sprite(type : Const.Shields) -> AtlasTexture:
	var image = sprites_256_atlas.duplicate()
	image.region = Rect2(256 * type, 256, 512, 256)
	return image

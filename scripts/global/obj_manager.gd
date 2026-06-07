extends Node

@export var actions_dict : Dictionary[Const.Actions, PackedScene]
@export var weapons_dict : Dictionary[Const.Weapons, PackedScene]
@export var shields_dict : Dictionary[Const.Shields, PackedScene]
@export var enemies_dict : Dictionary[Const.Enemies, PackedScene]
@export var player_classes_dict : Dictionary[Const.PlayerClasses, PackedScene]

@export var card_obj : PackedScene
@export var enemy_obj : PackedScene
@export var sprites_256_atlas : AtlasTexture
@export var sprites_512_atlas : AtlasTexture

func get_rand_action_data(dict = actions_dict) -> CardData:
	return dict[randi_range(0, Const.Actions.size() - 1)].instantiate()

func get_action_datas(\
	types : Array[Const.Actions], 
	dict = actions_dict) -> Array[CardData]:
	var arr : Array[CardData]
	for type in types:
		arr.append(dict[type].instantiate())
	return arr

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

func get_rand_enemy_data() -> EnemyData:
	return enemies_dict[randi_range(0, Const.Enemies.size() - 1)].instantiate()

func get_rand_player_class_data() -> EntityData:
	return player_classes_dict[randi_range(0, Const.Enemies.size() - 1)].instantiate()

func get_rand_action_obj() -> CardObj:
	return card_obj.instantiate().config(get_rand_action_data())

func get_rand_weapon_obj() -> CardObj:
	return card_obj.instantiate().config(get_rand_weapon_data())

func get_rand_shield_obj() -> CardObj:
	return card_obj.instantiate().config(get_rand_shield_data())

func get_card_obj(data : CardData) -> CardObj:
	return card_obj.instantiate().config(data)

func get_enemy_obj(data : EnemyData) -> Enemy:
	return enemy_obj.instantiate().config(data)

func get_rand_enemy_obj() -> Enemy:
	return get_enemy_obj(get_rand_enemy_data())

func get_action_sprite(type : Const.Actions) -> AtlasTexture:
	var image = sprites_256_atlas.duplicate()
	match type:
		Const.Actions.SLASH:
			image.region = Rect2(256, 0, 256, 256)
		Const.Actions.DEFEND:
			image.region = Rect2(0, 512, 256, 256)
		_:
			image.region = Rect2(256 * type, 256, 256, 256)
	return image

func get_weapon_sprite(type : Const.Weapons) -> AtlasTexture:
	var image = sprites_256_atlas.duplicate()
	image.region = Rect2(256 * type, 0, 256, 256)
	return image

func get_shield_sprite(type : Const.Shields) -> AtlasTexture:
	var image = sprites_256_atlas.duplicate()
	image.region = Rect2(256 * type, 512, 256, 256)
	return image

func get_enemy_sprite(type : Const.Enemies, has_alt = false) -> AtlasTexture:
	var image = sprites_512_atlas.duplicate()
	image.region = Rect2(\
		512 * type, 
		0 if !has_alt else 512 * randi_range(0, 1),
		512, 
		512)

	return image

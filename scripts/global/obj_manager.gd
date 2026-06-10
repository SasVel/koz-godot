extends Node

@export var actions_dict : Dictionary[Const.Actions, PackedScene]
@export var weapons_dict : Dictionary[Const.Weapons, PackedScene]
@export var shields_dict : Dictionary[Const.Shields, PackedScene]
@export var enemies_dict : Dictionary[Const.Enemies, PackedScene]
@export var status_effects_dict : Dictionary[Const.StatusEffects, PackedScene]
@export var player_classes_dict : Dictionary[Const.PlayerClasses, PackedScene]

@export var card_obj : PackedScene
@export var enemy_obj : PackedScene
@export var action_mini_obj : PackedScene
@export var eff_mini_obj : PackedScene

@export var sprites_128_atlas : AtlasTexture
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

func get_rand_eff_data() -> StatusEffData:
	return status_effects_dict[randi_range(0, Const.StatusEffects.size() - 1)].instantiate()

func get_rand_action_obj() -> CardObj:
	return card_obj.instantiate().config(get_rand_action_data())

func get_rand_action_objects(num) -> Array[CardObj]:
	var objects : Array[CardObj] = []
	for i in range(num):
		objects.append(get_rand_action_obj())
	return objects

func get_rand_weapon_obj() -> CardObj:
	return card_obj.instantiate().config(get_rand_weapon_data())

func get_rand_shield_obj() -> CardObj:
	return card_obj.instantiate().config(get_rand_shield_data())

func get_card_obj(data : CardData) -> CardObj:
	return card_obj.instantiate().config(data)

func get_enemy_obj(data : EnemyData) -> Enemy:
	return enemy_obj.instantiate().config(data)

func get_action_mini_obj(data : CardData) -> ActionMiniDisplay:
	return action_mini_obj.instantiate().config(data)

func get_eff_mini_obj(data : StatusEffData) -> StatusEffDisplay:
	return eff_mini_obj.instantiate().config(data)

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

func get_action_mini_sprite(type : Const.Actions) -> Texture2D:
	var image = sprites_128_atlas.duplicate()
	var x_pos = 0
	match type:
		Const.Actions.SLASH:
			x_pos = 0
		Const.Actions.DEFEND:
			x_pos = 128
		_:
			x_pos = 0
	image.region = Rect2(x_pos, 0, 128, 128)
	return image

func get_action_color(type : Const.Actions) -> Color:
	var color : Color
	match type:
		Const.Actions.SLASH:
			color = Const.ATTACK_COLOR
		Const.Actions.DEFEND:
			color = Const.DEFEND_COLOR
		_:
			color = Const.ACTION_COLOR
	return color

func get_effect_sprite(type : Const.StatusEffects) -> Texture2D:
	var image = sprites_128_atlas.duplicate()
	match type:
		Const.StatusEffects.CHANGE_PHASE_ATK:
			## Image to change icon.
			image.region = Rect2(512, 0, 128, 128)
			var sword_img = get_weapon_sprite(Const.Weapons.SWORD).get_image()
			sword_img.shrink_x2()
			#image.get_image().blit_rect(sword_img, sword_img.get_used_rect() Vector2.ZERO)
		_:
			image.region = Rect2(384, 0, 128, 128)
	return image

func get_effect_color(type : Const.StatusEffects) -> Color:
	var color : Color
	match type:
		Const.StatusEffects.STRENGTH:
			color = Const.ATTACK_COLOR
		_:
			color = Const.ACTION_COLOR
	return color

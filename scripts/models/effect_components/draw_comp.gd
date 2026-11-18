extends EffectComponent
class_name DrawComp

@export var type : Const.CardTypes
@export var count : int

@export_category("optional")
@export var is_suit : bool = false
## Overrides suit_type, but needs is_suit active
@export var is_suit_koz : bool = false
@export var suit_type : Const.SuitTypes

func activate():
	match type:
		Const.CardTypes.ACTION:
			source.draw_actions(count, \
				[Game.curr_room.koz_suit if is_suit_koz else suit_type] if is_suit else [])
		Const.CardTypes.WEAPON:
			var weapons : Array[ToolData]
			for i in range(count):
				weapons.append(ObjManager.get_rand_weapon_data())
			(source as Player).add_tools(weapons)
		Const.CardTypes.SHIELD:
			var shields : Array[ToolData]
			for i in range(count):
				shields.append(ObjManager.get_rand_shield_data())
			(source as Player).add_tools(shields)
	super()

func generate_desc() -> String:
	return "Draw %.f %s%s%s." \
		% [count, \
		Const.CardTypes.keys()[type], \
		"" if count <= 1 else "S", \
		(" of Koz suit" if is_suit_koz else ("of suit " + Const.SuitTypes.keys()[suit_type])) if is_suit else ""]

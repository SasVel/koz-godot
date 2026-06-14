extends EffectComponent
class_name DrawComp

@export var type : Const.CardTypes
@export var count : int

func activate():
	match type:
		Const.CardTypes.ACTION:
			source.draw_actions(count)
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
	return "Draw %.f %s%s." % [count, Const.CardTypes.keys()[type], "" if count <= 1 else "S"]

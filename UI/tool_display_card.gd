extends Control
class_name ToolDisplayCard

func config(data : ToolData):
	var image : Texture2D
	var title_text : String
	match data.type:
		Const.CardTypes.ACTION:
			title_text = Const.Actions.keys()[data.actionType]
			image = ObjManager.get_action_sprite(data.actionType)
			%CardIconRect.self_modulate = Const.COMPLIMENTARY_COLOR
		Const.CardTypes.WEAPON:
			title_text = Const.Weapons.keys()[data.weaponType]
			image = ObjManager.get_weapon_sprite(data.weaponType)
			%CardIconRect.self_modulate = Const.COMPLIMENTARY_COLOR
		Const.CardTypes.SHIELD:
			title_text = Const.Shields.keys()[data.shieldType]
			image = ObjManager.get_shield_sprite(data.shieldType)
			%CardIconRect.self_modulate = Const.COMPLIMENTARY_COLOR

	%TitleLabel.text = UIHelper.pascal_to_readable_text(title_text)
	self.tooltip_text = data.generate_desc()
	%CardIconRect.texture = image
	%CardIconShadow.texture = image
	%TempoDisplay.config(Const.ACCENT_COLOR, data.tempoCost, data.tempo_changed)
	update_durability(data.durability)
	return self

func update_durability(val):
	%DurabilityLabel.text = "|"
	for i in range(val):
		%DurabilityLabel.text += "#"
	%DurabilityLabel.text += "|"

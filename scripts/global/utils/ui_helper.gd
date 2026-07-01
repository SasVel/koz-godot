extends Node
class_name UIHelper

## Converts PascalCase text to readable format with spaces and proper capitalization
## Example: "ThisIsText" -> "This is text"
static func pascal_to_readable_text(text : String) -> String:
	var res : String = ""
	var prev_char : String = ""

	for i in range(text.length()):
		var ch : String = text.substr(i, 1)

		if ch.to_upper() == ch:
			if i > 0 and text.substr(i - 1, 1).to_upper() == text.substr(i - 1, 1):
				res += ch
			elif prev_char.is_empty() \
				or ch == " " \
				or ch == ",":
				res += ch
			else:
				res += " " + ch
		else:
			res += ch

		prev_char = ch

	res = res.replace("_", " ")
	return res

static func tween_eff_trails(source_center_pos : Vector2, eff_comp : EffectComponent):
	if eff_comp is DamageComp: 
		var dmg_comp = (eff_comp as DamageComp)
		for target in dmg_comp.targets:
			var trail : TrailEffect = ObjManager.trail_eff_scn.instantiate()
			trail.config(Const.ACCENT_COLOR,\
			source_center_pos,\
			target.entity_bar.global_position + target.entity_bar.size / 2)
			Game.visualEffectsContainer.add_child(trail)
			await trail.play()
	elif eff_comp is BlockComp:
		var block_comp = (eff_comp as BlockComp)
		var target = block_comp.source
		var trail : TrailEffect = ObjManager.trail_eff_scn.instantiate()
		trail.config(Const.COMPLIMENTARY_COLOR,\
		source_center_pos,\
		target.entity_bar.global_position + target.entity_bar.size / 2)
		Game.visualEffectsContainer.add_child(trail)
		await trail.play()

static func set_theme_colors(control : Control):
	var btn_stylebox : StyleBoxTexture
	# Normal stylebox edit
	btn_stylebox = control.theme.get_stylebox("normal", "Button")
	btn_stylebox.modulate_color = Const.BACKGROUND_LIGHTER_COLOR
	control.theme.set_stylebox("normal", "Button", btn_stylebox)

	# Pressed stylebox edit
	btn_stylebox = control.theme.get_stylebox("pressed", "Button")
	btn_stylebox.modulate_color = Const.BACKGROUND_LIGHTER_COLOR
	control.theme.set_stylebox("pressed", "Button", btn_stylebox)

	# Disabled stylebox edit
	btn_stylebox = control.theme.get_stylebox("disabled", "Button")
	btn_stylebox.modulate_color = Const.BACKGROUND_DARKER_COLOR
	control.theme.set_stylebox("disabled", "Button", btn_stylebox)

	# Panel container texture color
	var panel_container_stylebox = control.theme.get_stylebox("panel", "PanelContainer")
	panel_container_stylebox.modulate_color = Const.BACKGROUND_DARKER_COLOR
	control.theme.set_stylebox("panel", "PanelContainer", panel_container_stylebox)

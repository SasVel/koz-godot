@icon("./assets/icon.svg")
@tool
extends DialogueLabel

func _update_text() -> void:
	if is_instance_valid(dialogue_line):
		text = _format_str(dialogue_line.text)
	else:
		text = ""

func _format_str(str : String) -> String:
	str = str\
		.replace("<", "[font_size=22][outline_size=5]")\
		.replace(">", "[/outline_size][/font_size]")
	return str

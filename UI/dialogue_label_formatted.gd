@icon("./assets/icon.svg")
@tool
extends DialogueLabel

func _update_text() -> void:
	if is_instance_valid(dialogue_line):
		text = _format_text(dialogue_line.text)
	else:
		text = ""

func _format_text(text : String) -> String:
	text = text\
		.replace("<", "[font_size=22][outline_size=5]")\
		.replace(">", "[/outline_size][/font_size]")
	return text

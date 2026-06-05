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

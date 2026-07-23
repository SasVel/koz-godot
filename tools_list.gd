extends HBoxContainer

var isOn : bool = false

func _ready() -> void:
	Game.on_start_first_turn.connect(tween_tools_offset.bind(true))
	Game.on_rooms_completed.connect(func(_num): tween_tools_offset(false))

func _on_child_entered_tree(node: Node) -> void:
	node.offset_transform_position.y = 0 if isOn else 200

func _on_sort_children() -> void:
	for child in self.get_children().filter(func(x): return x is CardObj):
		child.set_defaults()

func tween_tools_offset(isOpen : bool):
	isOn = isOpen

	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_ELASTIC)
	for child in %ToolsList.get_children():
		if isOpen:
			tween.tween_property(child, "offset_transform_position:y", 0, 0.8).from(200)
		else:
			tween.tween_property(child, "offset_transform_position:y", 200, 0.8).from(0)

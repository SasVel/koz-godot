extends HBoxContainer

var isOn : bool = false

func _ready() -> void:
	Game.on_start_first_turn.connect(tween_tools_offset.bind(true))
	Game.on_rooms_completed.connect(func(_num): tween_tools_offset(false))

func _on_child_entered_tree(node: Node) -> void:
	await node.ready
	if isOn:
		node.curr_tween_state = CardObj.TweenState.Idle
		node.offset_transform_position.y = 0
	else:
		node.curr_tween_state = CardObj.TweenState.None
		node.offset_transform_position.y = 200

func _on_sort_children() -> void:
	for child in self.get_children().filter(func(x): return x is CardObj):
		child.set_defaults()

func tween_tools_offset(isOpen : bool):
	isOn = isOpen

	self.queue_sort()
	await self.sort_children
	var children = %ToolsList.get_children()
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_ELASTIC)
	for child in children:
		if isOpen:
			tween.tween_property(child, "offset_transform_position:y", 0, 0.8).from(200)
		else:
			tween.tween_property(child, "offset_transform_position:y", 200, 0.8).from(0)

	await tween.finished
	for child in children:
		if isOpen:
			child.curr_tween_state = CardObj.TweenState.Idle
		else:
			child.curr_tween_state = CardObj.TweenState.None

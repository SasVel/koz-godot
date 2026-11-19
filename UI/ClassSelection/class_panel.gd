extends PanelContainer

@onready var data : ClassData
@export var left_hand_container : HBoxContainer
@export var right_hand_container : HBoxContainer

signal finished

func config(data_ : ClassData):
	cleanup()

	data = data_
	%TitleLabel.text = data.entity_name.capitalize()
	%SuitIconRect.texture = ObjManager.get_suit_sprite(data.suit)
	var suit_color = ObjManager.get_suit_color(data.suit)
	%SuitIconRect.self_modulate = suit_color
	%ClassIcon.texture = ObjManager.get_class_icon(data.player_class)
	%ClassIcon.modulate = suit_color

	%DescLabel.text = data.desc
	%HealthLabel.text = "Health: %.f" % data.default_stats.Health.maxValue
	%TempoLabel.text = "Tempo: %.f" % data.default_stats.Tempo.maxValue
	%HandSizeLabel.text = "Hand Size: %.f" % data.card_hand_size

	for tool in data.get_possible_tools_for_hand(0):
		_tool_data_to_container(tool, left_hand_container)

	for tool in data.get_possible_tools_for_hand(1):
		_tool_data_to_container(tool, right_hand_container)
	return self

func _tool_data_to_container(tool_data : ToolData, container : Control):
		var tool_obj : ToolDisplayCard = ObjManager.get_tool_display_obj(tool_data)
		tool_obj.scale = Vector2(0.1, 0.1)
		container.add_child(tool_obj)

func cleanup():
	for child in left_hand_container.get_children():
		child.queue_free()
	for child in right_hand_container.get_children():
		child.queue_free()

func _on_choose_btn_pressed() -> void:
	Game.default_class = data.player_class
	finished.emit()

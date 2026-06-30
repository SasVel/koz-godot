extends PanelContainer

@onready var data : ClassData

signal finished

func config(data_ : ClassData):
	data = data_
	%TitleLabel.text = data.entity_name.capitalize()
	%DescLabel.text = data.desc
	%HealthLabel.text = "Health: %.f" % data.default_stats.Health.maxValue
	%TempoLabel.text = "Tempo: %.f" % data.default_stats.Tempo.maxValue
	%HandSizeLabel.text = "Hand Size: %.f" % data.default_stats.HandSize.maxValue
	data.load_tools()
	for tool in data.starting_tools:
		var tool_obj : ToolDisplayCard = ObjManager.get_tool_display_obj(tool)
		tool_obj.scale = Vector2(0.2, 0.2)
		%ToolsContainer.add_child(tool_obj)
	return self

func _on_choose_btn_pressed() -> void:
	Game.default_class = data.player_class
	finished.emit()

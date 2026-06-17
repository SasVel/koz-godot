extends Entity
class_name Player

@export var player_bar : EntityBar
var equipped_tools : Array[ToolData]

signal tools_changed(tools)

func config(data_ : EntityData):
	super(data_)
	var class_data = (data as ClassData)
	add_tools(class_data.starting_tools)

func _ready() -> void:
	config(ObjManager.player_classes_dict[Game.default_class].instantiate())
	player_bar.config(stats.Health, stats.Block)
	super()

func on_changed_phase(val : Game.Phases):
	if val == Game.Phases.ATTACK:
		apply_attack_phase_modifiers()
	elif val == Game.Phases.DEFEND:
		apply_defend_phase_modifiers()

#region Tools
func add_tool(tool : ToolData):
	self.equipped_tools.append(tool)
	tool.config_source(self)
	%ToolDatas.add_child(tool)
	tools_changed.emit(equipped_tools)

func add_tools(tools : Array):
	for tool in tools:
		self.equipped_tools.append(tool)
		tool.config_source(self)
		%ToolDatas.add_child(tool)
	tools_changed.emit(equipped_tools)

func remove_tool(tool : ToolData):
	self.equipped_tools.erase(tool)
	%ToolDatas.remove_child(tool)
	tools_changed.emit(equipped_tools)

func replace_tool(tool_to_replace, tool_to_be_replaced):
	remove_tool(tool_to_be_replaced)
	add_tool(tool_to_replace)

#endregion

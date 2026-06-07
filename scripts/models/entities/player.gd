extends Entity
class_name Player

@export var default_class : Const.PlayerClasses
var equipped_tools : Array[ToolData]

signal tools_changed(tools)

func config(data_ : EntityData):
	super(data_)
	var class_data = (data as ClassData)
	add_tools(class_data.starting_tools)

func _ready() -> void:
	super()
	config(ObjManager.player_classes_dict[default_class].instantiate())

#region Tools
func add_tool(tool : Tool):
	self.equipped_tools.append(tool)
	%ToolDatas.add_child(tool)
	tools_changed.emit(equipped_tools)
	
func add_tools(tools : Array):
	for tool in tools:
		self.equipped_tools.append(tool)
		%ToolDatas.add_child(tool)
	tools_changed.emit(equipped_tools)

#endregion

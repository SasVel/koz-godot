extends Control
class_name ClassSelectionPopup

@onready var classPanelScn = preload("res://UI/ClassSelection/class_panel.tscn")

signal finished

func _ready() -> void:
	for key in ObjManager.player_classes_dict:
		var panelInst = classPanelScn.instantiate().config(ObjManager.player_classes_dict[key].instantiate())
		%Container.add_child(panelInst)
		panelInst.finished.connect(func(): finished.emit())

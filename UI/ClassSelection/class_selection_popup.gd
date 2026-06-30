extends Control
class_name ClassSelectionPopup

@onready var classPanelScn = preload("res://UI/ClassSelection/class_panel.tscn")

signal finished
signal cancelled

func _ready() -> void:
	for key in ObjManager.player_classes_dict:
		var panelInst = classPanelScn.instantiate().config(ObjManager.player_classes_dict[key].instantiate())
		%Container.add_child(panelInst)
		panelInst.finished.connect(func(): finished.emit())

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		cancelled.emit()
		self.queue_free()

extends Control
class_name ClassSelectionPopup

@onready var class_panel = %ClassPanel
@onready var displayed_class_idx : int = 0

signal finished
signal cancelled

func _ready() -> void:
	for key in ObjManager.player_classes_dict:
		var button = Button.new()
		button.text = Const.PlayerClasses.keys()[key]
		button.pressed.connect(load_class_info.bind(key))
		%ClassSelectionContainer.add_child(button)

	class_panel.finished.connect(func(): finished.emit())

func load_class_info(idx : int):
	class_panel.config(ObjManager.player_classes_dict[idx].instantiate() as ClassData)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		cancelled.emit()
		self.queue_free()

extends GamePopup
class_name ClassSelectionPopup

@onready var class_panel = %ClassPanel
@onready var displayed_class_idx : int = 0
@onready var selected_button : Button :
	set(button):
		if selected_button != null:
			selected_button.offset_transform_scale = Vector2.ONE
		button.offset_transform_scale = Vector2(1.2,1.2)
		selected_button = button

signal cancelled

func _ready() -> void:
	for key in ObjManager.player_classes_dict:
		var button = Button.new()
		button.pivot_offset_ratio = Vector2(0.5, 0.5)
		button.offset_transform_enabled = true
		button.text = Const.PlayerClasses.keys()[key]
		button.pressed.connect(_on_button_press.bindv([button, key]))
		%ClassSelectionContainer.add_child(button)

	_on_button_press(%ClassSelectionContainer.get_child(0), 0)
	class_panel.finished.connect(func(): finished.emit())

func set_focus() -> void:
	var container : HBoxContainer = %ClassSelectionContainer
	if container.get_child_count() > 0:
		container.get_child(0).grab_focus()

func _on_button_press(button, key):
	selected_button = button
	load_class_info(key)

func load_class_info(idx : int):
	class_panel.config(ObjManager.player_classes_dict[idx].instantiate() as ClassData)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		cancelled.emit()
		self.queue_free()

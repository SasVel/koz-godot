extends Control
class_name DragObject

## Set custom minimum size, the object will have a size of 0,0 otherwise.

@export var title : String
@export_multiline var description : String
@export var fauxShifted : bool = false
@export var fauxShiftDeg : float = 15.0
@export var fauxTweenSpeed : float = 0.1
@export var container : Control

var isPickedUp : bool = false
var isEquipped : bool = false

var dragObject : Control

signal drag_started(caller : DragObject)
signal drag_ended(caller : DragObject)

func _get_drag_data(_at_position : Vector2):
	var data = {}

	dragObject = self.duplicate(DUPLICATE_DEFAULT)

	dragObject.set_deferred("size", dragObject.size)
	dragObject.scale = Vector2.ONE
	dragObject.z_index = 100

	dragObject.position = get_local_mouse_position() * -1
	if fauxShifted: faux_shift(container)

	var control = Control.new()
	control.add_child(dragObject)

	isPickedUp = true
	self.visible = false
	set_drag_preview(control)
	data["object"] = self
	return data

func change_opacity(val : float):
	self.modulate.a = val

func _notification(what):
	match what:
		NOTIFICATION_DRAG_BEGIN:
			self.mouse_filter = Control.MOUSE_FILTER_IGNORE
		NOTIFICATION_DRAG_END:
			self.mouse_filter = Control.MOUSE_FILTER_PASS

	if !isPickedUp: return

	match what:
		NOTIFICATION_DRAG_BEGIN:
			drag_started.emit(self)
			Game.is_object_dragged = true
			dragObject.change_opacity(0.9)
		NOTIFICATION_DRAG_END:
			self.visible = true
			isPickedUp = false
			reset_faux_shift()
			drag_ended.emit(self)
			Game.is_object_dragged = false

func faux_shift(dragObj : Control):
	var center = self.global_position + (dragObj.size / 2)
	var distanceToCenter = get_global_mouse_position().distance_to(center)
	var rotY : float = (distanceToCenter / (dragObj.size.y / 2)) * fauxShiftDeg
	var rotX : float = (distanceToCenter / (dragObj.size.x / 2)) * fauxShiftDeg

	if get_global_mouse_position().y < center.y:
		rotX *= -1
	if get_global_mouse_position().x >= center.x:
		rotY *= -1

	#dragObj.material.set_shader_parameter("rot_y_deg", rotY)
	Obj.tween_shader_parameter(dragObj, "rot_y_deg", 0.0, rotY, fauxTweenSpeed)
	#dragObj.material.set_shader_parameter("rot_x_deg", rotX)
	Obj.tween_shader_parameter(dragObj, "rot_x_deg", 0.0, rotX, fauxTweenSpeed)

func reset_faux_shift():
	container.material.set_shader_parameter("rot_y_deg", 0)
	container.material.set_shader_parameter("rot_x_deg", 0)

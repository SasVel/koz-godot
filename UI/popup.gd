extends Control
class_name GamePopup

@export var is_closeable : bool = false

signal finished

func close():
	finished.emit()

extends Control

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	var obj = data["object"]
	if obj is CardObj and !obj.data.isOffensive:
		return true
	return false

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var objData = data["object"].data
	objData.activate()

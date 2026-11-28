extends GutTest

const GREATAXE_SCENE := preload("res://entities/card_datas/tools/greataxe_tool_data.tscn")


func test_uses_type_assigned_after_construction() -> void:
	var comp := StatusEffComp.new()
	comp.type = Const.StatusEffects.FRAIL

	assert_eq(comp.data.type, Const.StatusEffects.FRAIL,
		"Type assigned after construction must be used")
	_cleanup(comp)


func test_uses_stacks_assigned_after_construction() -> void:
	var comp := StatusEffComp.new()
	comp.stacks = 2

	assert_eq(comp.data.stacks, 2,
		"Stacks assigned after construction must be used")
	_cleanup(comp)


func test_greataxe_scene_adds_frail() -> void:
	var greataxe := GREATAXE_SCENE.instantiate()
	var comp := greataxe.get_node(
		"Components/ChanceComponent/Components/StatusEffComp") as StatusEffComp

	assert_eq(comp.data.type, Const.StatusEffects.FRAIL)

	_cleanup(comp)
	greataxe.free()


func _cleanup(comp : StatusEffComp) -> void:
	var eff_data := comp.data
	comp.free()
	eff_data.free()

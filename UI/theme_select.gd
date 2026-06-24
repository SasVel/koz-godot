extends OptionButton

func _ready() -> void:
	for th in Const.themes:
		add_item(th)

	select(0)

func _on_item_selected(index: int) -> void:
	Const.load_palette(index)

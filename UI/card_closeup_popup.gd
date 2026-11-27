extends GamePopup

func set_focus() -> void:
	%CloseButton.grab_focus()

func display(card : CardObj):
	card.offset_transform_scale = Vector2(1.5, 1.5)
	%CardContainer.add_child(card)

func close():
	super.close()
	self.queue_free()

func _on_close_button_pressed() -> void:
	close()

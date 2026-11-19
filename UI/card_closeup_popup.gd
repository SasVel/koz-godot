extends GamePopup

func display(card : CardObj):
	card.offset_transform_scale = Vector2(1.5, 1.5)
	%CardContainer.add_child(card)

func close():
	super.close()
	self.queue_free()

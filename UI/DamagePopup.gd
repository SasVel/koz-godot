extends Marker2D

@onready var label = $Label

func _ready():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_parallel(true)
	
	queue_free()

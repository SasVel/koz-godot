extends Timer
class_name EndTurnTimer

@export var display : RadialDisplay

func _ready() -> void:
	display.visible = false

func config(max_time : float):
	self.wait_time = max_time
	display.config(max_time, max_time)

func timer_start(time):
	config(time)
	self.start(time)
	display.visible = true

func timer_stop():
	self.stop()
	display.visible = false

func _physics_process(_delta: float) -> void:
	if self.is_stopped(): return
	display.update(self.time_left)

func _on_timeout() -> void:
	Game.end_turn()
	display.visible = false
	await Game.on_start_turn_layer_2
	display.visible = true
	self.start()

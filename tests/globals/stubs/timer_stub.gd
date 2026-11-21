extends EndTurnTimer


var timer_start_calls: Array[float] = []


# EndTurnTimer._ready() assumes display is configured; tests don't use it.
func _ready() -> void:
	pass


func _physics_process(_delta: float) -> void:
	pass


func config(_max_time: float) -> void:
	pass


func timer_start(time: float) -> void:
	timer_start_calls.append(time)


func timer_stop() -> void:
	stop()

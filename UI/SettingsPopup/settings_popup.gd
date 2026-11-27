extends GamePopup
class_name SettingsPopup

var mainBusIndex : int
var musicBusIndex : int
var sfxBusIndex : int

func _ready() -> void:
	mainBusIndex = AudioServer.get_bus_index("Master")
	musicBusIndex = AudioServer.get_bus_index("Music")
	sfxBusIndex = AudioServer.get_bus_index("SFX")
	config_vol_sliders()

func set_focus() -> void:
	%MasterSlider.grab_focus()

func config_vol_sliders():
	%MasterSlider.value = db_to_linear(AudioServer.get_bus_volume_db(mainBusIndex))
	%MusicSlider.value = db_to_linear(AudioServer.get_bus_volume_db(musicBusIndex))
	%SFXSlider.value = db_to_linear(AudioServer.get_bus_volume_db(sfxBusIndex))

func _on_master_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(mainBusIndex, linear_to_db(value))

func _on_music_s_lider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(musicBusIndex, linear_to_db(value))

func _on_sfx_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(sfxBusIndex, linear_to_db(value))

func _on_close_button_pressed() -> void:
	finished.emit()
	self.queue_free()

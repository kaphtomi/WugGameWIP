extends Control

@onready var SFX_BUS_ID = AudioServer.get_bus_index("SFX")
@onready var MUSIC_BUS_ID = AudioServer.get_bus_index("Music")

func _enter_tree():
	$UIOrganizer/VBoxContainer/GridContainer/MusicSlider.value = Settings.music_volume
	$UIOrganizer/VBoxContainer/GridContainer/SFXSlider.value = Settings.sfx_volume


func _exit_tree():
	Settings.save()

func _on_texture_button_pressed():
	get_tree().current_scene.to_start_screen()
	
func _on_music_slider_value_changed(value):
	AudioServer.set_bus_volume_db(MUSIC_BUS_ID, linear_to_db(value))
	AudioServer.set_bus_mute(MUSIC_BUS_ID, value < 0.05)
	Settings.music_volume = value

func _on_sfx_slider_value_changed(value):
	AudioServer.set_bus_volume_db(SFX_BUS_ID, linear_to_db(value))
	AudioServer.set_bus_mute(SFX_BUS_ID, value < 0.05)
	Settings.sfx_volume = value

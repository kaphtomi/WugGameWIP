extends Node

var config: ConfigFile

var music_volume
var sfx_volume

# Called when the node enters the scene tree for the first time.
func _init():
	config = ConfigFile.new()
	config.load("user://settings.cfg")
		
	music_volume = config.get_value("settings", "music_volume", 1.0)
	sfx_volume = config.get_value("settings", "sfx_volume", 1.0)

func save():
	config.set_value("settings", "music_volume", music_volume)
	config.set_value("settings", "sfx_volume", sfx_volume)
	config.save("user://settings.cfg")

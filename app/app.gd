extends Node

var GameScreen = preload("res://app/game_screen/game_screen.tscn")
var StartScreen = preload("res://app/start_screen/start_screen.tscn")
var SettingsScreen = preload("res://app/settings_screen.tscn")
var GameOverScreen = preload("res://app/game_over_screen/game_over_screen.tscn")
#var ScoreScreen


# Called when the node enters the scene tree for the first time.
func _ready():
	$StartScreen.start.connect(_on_start)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db( Settings.music_volume))
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"),  Settings.music_volume < 0.05)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(Settings.sfx_volume))
	AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), Settings.sfx_volume < 0.05)

func _on_start():
	reset()
	#var game_screen = GameScreen.instantiate()
	#add_child(game_screen)

func to_start_screen():
	reset()
	var start_screen = StartScreen.instantiate()
	add_child(start_screen)
	
func to_game_screen():
	reset()
	var game_screen = GameScreen.instantiate()
	add_child(game_screen)

func to_settings_screen():
	reset()
	var settings_screen = SettingsScreen.instantiate()
	add_child(settings_screen)
	
func to_game_over_screen():
	reset()
	var game_over_screen = GameOverScreen.instantiate()
	add_child(game_over_screen)
	
func reset():
	for child in get_children():
		if child != GlobalVariables:
			child.queue_free()
	Engine.time_scale=1.0

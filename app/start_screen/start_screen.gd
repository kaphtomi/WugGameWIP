extends Control

signal start

func _ready():
	pass

func _on_texture_button_pressed():
	get_tree().current_scene.to_game_screen()

func _on_settings_button_pressed():
	get_tree().current_scene.to_settings_screen()

func _on_snooze_button_pressed():
	get_tree().quit()

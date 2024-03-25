extends Control

signal start

func _ready():
	pass

func _on_start_button_pressed():
	#start.emit()
	get_tree().change_scene_to_file("res://app/game_screen/game_screen.tscn")

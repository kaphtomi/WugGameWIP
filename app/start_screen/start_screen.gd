extends Control

signal start

func _ready():
	pass


func _on_texture_button_pressed():
	get_tree().change_scene_to_file("res://app/game_screen/game_screen.tscn")

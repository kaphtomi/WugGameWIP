extends Node

#var GameScreen = preload("res://app/game_screen/game_screen.gd")

# Called when the node enters the scene tree for the first time.
func _ready():
	$StartScreen.start.connect(_on_start)

func _on_start():
	for child in get_children():
		child.queue_free()
	#var game_screen = GameScreen.instantiate()
	#add_child(game_screen)

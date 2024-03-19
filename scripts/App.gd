extends Node

const StartScreen = preload("res://scenes/StartScreen.tscn")
const GameScreen = preload("res://scenes/GameScreen.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	var start_screen : StartScreen = StartScreen.instantiate()
	start_screen.start.connect(_on_start)
	add_child(start_screen)

func _on_start():
	for child in get_children():
		child.queue_free()
	var game_screen = GameScreen.instantiate()
	add_child(game_screen)

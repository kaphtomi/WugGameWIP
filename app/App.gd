extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	$StartScreen.start.connect(_on_start)

func _on_start():
	for child in get_children():
		child.queue_free()

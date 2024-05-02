extends Container


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_game_screen_game_pause():
	show()
	pass # Replace with function body.


func _on_game_screen_game_unpause():
	hide()
	pass # Replace with function body.


func _on_continue_pressed():
	get_parent().get_parent().unpause_game()
	pass # Replace with function body.




func _on_home_pressed():
	get_tree().current_scene.to_start_screen()
	pass # Replace with function body.


func _on_restart_pressed():
	get_tree().current_scene.to_game_screen()
	pass # Replace with function body.

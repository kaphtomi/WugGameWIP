extends Control

func _on_game_screen_game_pause():
	show()


func _on_game_screen_game_unpause():
	hide()


func _on_continue_pressed():
	get_parent().get_parent().unpause_game()
	pass # Replace with function body.


func _on_home_pressed():
	get_tree().current_scene.to_start_screen()
	pass # Replace with function body.


func _on_restart_pressed():
	get_tree().current_scene.to_game_screen()
	pass # Replace with function body.

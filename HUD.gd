extends CanvasLayer

signal start_game

func show_message(text):
	
	$Message.text = text
	$Message.show()
	
func _on_start_button_pressed():
	$StartButton.hide()
	start_game.emit()
	

	
	

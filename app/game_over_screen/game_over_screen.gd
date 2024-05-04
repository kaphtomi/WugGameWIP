extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	$UIOrganizer/VOrganizer/ScoreLabel.text = "Score: " + str(GlobalVariables.score)


func _on_restart_button_pressed():
	get_tree().current_scene.to_start_screen()

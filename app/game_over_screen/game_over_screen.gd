extends Control

var final_score = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	print("loaded game over screen")
	final_score = GlobalVariables.final_score
	$Organizer/ScoreLabel.text = "Score: " + str(final_score)
	#$Organizer.position = Vector2(get_viewport_rect().size / 2)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_restart_button_pressed():
	get_tree().change_scene_to_file("res://app/start_screen/start_screen.tscn")

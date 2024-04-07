extends Node2D

var final_score = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	final_score = GlobalVariables.final_score
	$Organizer/ScoreLabel.text = "Score: " + str(final_score)
	$Organizer.position = Vector2(get_viewport_rect().size / 2)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_restart_button_pressed():
	pass # Replace with function body.

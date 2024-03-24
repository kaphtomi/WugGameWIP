extends BoxContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#Connected to a signal from the textfield. Runs when enter is pressed
func _on_text_field_text_submitted(_new_text):
	var letterArray = $TextField.text.split("", false, 0)
	var update_wires : Dictionary
	$Label.text = $Label.text + $TextField.text + "\n "
	$TextField.clear()

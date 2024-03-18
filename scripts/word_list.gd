extends BoxContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Called when text is submitted in TextField
func _on_text_field_text_submitted(_new_text):
	var letterArray = $WordList/TextField.text.split("", false, 0)
	var update_wires : Dictionary
	$WordList/Label.text = $WordList/Label.text + $WordList/TextField.text + "\n "
	$WordList/TextField.clear()	

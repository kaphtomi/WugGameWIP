extends ScrollContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func word_list_updated(word_list: Array):
	$Label.text = ""
	for word in word_list:
		$Label.text += word + "\n"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

extends VBoxContainer

signal word_submitted
signal word_array_changed
signal text_field_changed

var word_array : Array

func _ready():
	$TextField.grab_focus()

func _on_text_submitted(_new_text : String):
	$TextField.clear()
	for word in word_array:
		if _new_text == word:
			return
	word_submitted.emit(_new_text)
	
func add_word(word : String):
	word_array.append(word)
	word_array.reverse()
	$WordList/Label.text = "\n".join(word_array)
	word_array.reverse()
	
func _on_text_changed(_new_text : String):
	text_field_changed.emit(_new_text)
	# render_words() if we want to filter

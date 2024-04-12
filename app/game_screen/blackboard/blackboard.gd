extends VBoxContainer

signal word_submitted
signal word_array_changed
signal text_field_changed
signal start_timer
var alphabetter = "ETAONSHRDLCUMWFGYPBVKJXQZI".split("", true, 0)

var word_array : Array

func _ready():
	$TextField.grab_focus()
	
func _process(_delta):
	#fuzz test
	#for i in 8:
		#fuzz()
	pass

func _on_text_submitted(_new_text : String):
	$TextField.clear()
	for word in word_array:
		if _new_text == word:
			return
	word_submitted.emit(_new_text)
	
func add_word(word : String):
	if word_array.size() == 0: start_timer.emit()
	word_array.append(word)
	
func _on_text_changed(_new_text : String):
	text_field_changed.emit(_new_text)

		
func starts_with(word : String):
	var input = $TextField.get_text()
	if (input == ""):
		return true
	var word_chars = word.split("")
	var input_chars = input.split("")
	for i in min(word_chars.size(),input_chars.size()):
		if (word_chars[i] != input_chars[i]):
			return false
	return true


func _on_text_field_text_changed(new_text):
	text_field_changed.emit(new_text)
	

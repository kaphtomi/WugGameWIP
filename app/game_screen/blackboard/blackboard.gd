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
	$WordList.word_list_updated(word_array)
	word_array_changed.emit()

func _on_word_array_changed():
	render_words()
	
func _on_text_changed(_new_text : String):
	text_field_changed.emit(_new_text)
	# render_words() if we want to filter

func render_words():
	var list : ItemList = $WordList
	list.clear() # we rerender the whole list so that later on we can 
	# filter the list according to the current word being typed, or
	# change its color to show potential collisions
	for word : String in word_array:
		list.add_item(word)

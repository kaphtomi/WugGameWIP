extends Control


const InputResonse = preload("res://used_words_rows.tscn")
	 
onready var used_word_rows = $Control/UsedWordsList/UsedWordsRows
	
func _on_Input_text_entered(new_text: String) -> void:
	var input_response = InputResonse.instance()
	used_word_rows.add_child(input_response)

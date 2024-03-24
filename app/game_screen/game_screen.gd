extends Control
	
func _ready():
	call_deferred("ready_circuit")
	
func ready_circuit():
	$Circuit.generate()

func _on_blackboard_word_submitted(word : String):
	if $Circuit.is_word_in_circuit(word):
		$Blackboard.add_word(word)
	

	

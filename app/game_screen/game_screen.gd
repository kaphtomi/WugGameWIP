extends Control
	
func _ready():
	call_deferred("ready_circuit")
	
func ready_circuit():
	$CircuitAndBlackboard/Circuit.generate()
	$CircuitAndBlackboard/Circuit.position = Vector2()

func _on_blackboard_word_submitted(word : String):
	if $CircuitAndBlackboard/Circuit.is_word_in_circuit(word):
		$CircuitAndBlackboard/Blackboard.add_word(word)



extends Control
	
func _ready():
	call_deferred("ready_circuit")
	
func _on_circuit_broken():
	print("game over!")
	# replace with switching to a game over screen eventually
	var game_over_label = Label.new()
	game_over_label.text = "Game Over"
	game_over_label.size = 50
	game_over_label.position = Vector2(get_viewport_rect().size / 2)
	game_over_label.font_color = Color(0, 0, 0)
	add_child(game_over_label)

func ready_circuit():
	$CircuitAndBlackboard/Circuit.generate()
	$CircuitAndBlackboard/Circuit.position = Vector2()

func _on_blackboard_word_submitted(word : String):
	if $CircuitAndBlackboard/Circuit.is_word_in_circuit(word):
		$CircuitAndBlackboard/Blackboard.add_word(word)



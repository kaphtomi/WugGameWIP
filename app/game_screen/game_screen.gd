extends Control
var score = 0
var cur_score = 0
var fade = 0
	
func _ready():
	call_deferred("ready_circuit")
	
func _process(delta):
	var cur_score_init = cur_score
	cur_score = lerp(float(cur_score),float(score),delta*2)
	fade = fade-delta
	if fade<0:
		$Flow/Extras.text = ""
	if ceil(cur_score)!= ceil(cur_score_init):
		$Flow/Score.text = str(ceil(cur_score))

func ready_circuit():
	$CircuitAndBlackboard/Circuit.generate()
	$CircuitAndBlackboard/Circuit.position = Vector2()

func _on_blackboard_word_submitted(word : String):
	if $CircuitAndBlackboard/Circuit.is_word_in_circuit(word):
		$CircuitAndBlackboard/Circuit.score_word(word)
		$CircuitAndBlackboard/Blackboard.add_word(word)
		var score_plus = $CircuitAndBlackboard/Circuit.score - score
		score += score_plus
		$Flow/Extras.text = "+" + str(score_plus) + " " + word
		fade=2

func _on_circuit_circuit_broken():
	# replace with switching to a game over screen eventually
	fade = 1
	#var game_over_label = $Flow/Score
	#game_over_label.text = game_over_label.text + ", game over"
	GlobalVariables.final_score = score
	get_tree().change_scene_to_file("res://app/game_over_screen/game_over_screen.tscn")
	
	


func _on_blackboard_text_field_changed(new_text):
	$Label.text = new_text

extends Control
var score = 0
var cur_score = 0
var fade = 0
var game_is_over=false
	
func _ready():
	call_deferred("ready_circuit")

func _process(delta):
	var cur_score_init = cur_score
	cur_score = lerp(float(cur_score),float(score),delta*2)
	fade = fade-delta
	if fade < 0:
		$Flow/Extras.text = ""
		if game_is_over:
			var game_over_label = $Flow/Score
			game_over_label.text = game_over_label.text + ", game over"
			GlobalVariables.score = score
			print("changing scene")
			get_tree().change_scene_to_file("res://app/game_over_screen/game_over_screen.tscn")
	if ceil(cur_score)!= ceil(cur_score_init):
		$Flow/Score.text = str(ceil(cur_score))
	if cur_score == 5:
		$SpeechBubble.snooze_text = "Snoozing"
		
	

func ready_circuit():
	$CircuitAndBlackboard/Circuit.generate()
	$CircuitAndBlackboard/Circuit.position = Vector2()

func _on_circuit_word_submitted(word : String):
	if word == "/kill":
		$CircuitAndBlackboard/Circuit.kill_circuit()
	if true: #$CircuitAndBlackboard/Circuit.is_word_in_circuit(word):
		#$CircuitAndBlackboard/Circuit.score_word(word)
		#$CircuitAndBlackboard/Blackboard.add_word(word)
		var score_plus = $CircuitAndBlackboard/Circuit.score - score
		score += score_plus
		$Flow/Extras.text = "+" + str(score_plus) + " " + word
		fade=2
		change_state()

func _on_circuit_circuit_broken():
	fade = 1.5
	game_is_over=true

func _on_blackboard_text_field_changed(new_text):
	$CircuitAndBlackboard/Circuit.update_word(new_text)
	
	
func change_state():
	if score/100 % 3 == 2:
		GlobalVariables.switch_to_sleep()
	else:
		GlobalVariables.cur_zzz = GlobalVariables.WUG_ZZZ.AWAKE
	match score/100:
		0, 2:
			GlobalVariables.cur_dif=GlobalVariables.WUG_DIFF.EASY
		1, 3, 5, 6, 8:
			GlobalVariables.cur_dif=GlobalVariables.WUG_DIFF.MED
		4, 7, 9:
			GlobalVariables.cur_dif=GlobalVariables.WUG_DIFF.HARD
	if score/1000!=0:
		GlobalVariables.cur_dif=GlobalVariables.WUG_DIFF.HARD
		


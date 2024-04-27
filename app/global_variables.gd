extends Node

var score
enum WUG_ZZZ {AWAKE, SLEEP}
enum WUG_DIFF {EASY, MED, HARD}
var cur_zzz = WUG_ZZZ.AWAKE
var cur_dif = WUG_DIFF.EASY 
enum HighlightState {NONE, PATH, POTENTIAL }
var path_color = Color(1.0, .46, .78)
var potential_color = Color(.2,.9,1.0)
var red_color = Color(1.0, .4, .4)


signal switching_to_zzz_mode

func switch_to_sleep():
	if cur_zzz != WUG_ZZZ.SLEEP:
		cur_zzz = WUG_ZZZ.SLEEP
		switching_to_zzz_mode.emit()


const cursor_base_scale = 0.6

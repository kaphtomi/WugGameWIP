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

const cursor_base_scale = 0.6

signal switching_to_zzz_mode
signal switching_to_awake_mode
signal switching_to_easy_mode
signal switching_to_med_mode
signal switching_to_hard_mode

func switch_to_sleep():
	if cur_zzz != WUG_ZZZ.SLEEP:
		cur_zzz = WUG_ZZZ.SLEEP
		switching_to_zzz_mode.emit()

func switch_to_awake():
	if cur_zzz != WUG_ZZZ.AWAKE:
		cur_zzz = WUG_ZZZ.AWAKE
		switching_to_awake_mode.emit()

func switch_to_easy_mode():
	if cur_dif != WUG_DIFF.EASY:
		cur_dif = WUG_DIFF.EASY
		switching_to_easy_mode.emit()

func switch_to_med_mode():
	if cur_dif != WUG_DIFF.MED:
		cur_dif = WUG_DIFF.MED
		switching_to_med_mode.emit()

func switch_to_hard_mode():
	if cur_dif != WUG_DIFF.HARD:
		cur_dif = WUG_DIFF.HARD
		switching_to_hard_mode.emit()

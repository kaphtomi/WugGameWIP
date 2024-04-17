extends Node

var score
enum WUG_ZZZ {AWAKE, SLEEP}
enum WUG_DIFF {EASY, MED, HARD}
var cur_zzz = WUG_ZZZ.AWAKE
var cur_dif = WUG_DIFF.EASY
var color_none = Color.WHITE
var color_potential = Color(0.48, 0.81, 1.0)
var color_valid = Color(1.0, .46, .78)
var color_invalid = Color.RED

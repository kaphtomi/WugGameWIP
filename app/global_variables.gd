extends Node

var score
enum WUG_ZZZ {AWAKE, SLEEP}
enum WUG_DIFF {EASY, MED, HARD}
var cur_zzz = WUG_ZZZ.AWAKE
var cur_dif = WUG_DIFF.EASY 

signal switching_to_zzz_mode

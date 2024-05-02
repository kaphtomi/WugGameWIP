extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalVariables.switching_to_easy_mode.connect(easy_mode)
	GlobalVariables.switching_to_med_mode.connect(med_mode)
	GlobalVariables.switching_to_hard_mode.connect(hard_mode)

func easy_mode():
	get_parent().junction_mirroring_off()
	get_parent().reset_junction_rotations()

func med_mode():
	get_parent().junction_mirroring_on()
	get_parent().reset_junction_rotations()

func hard_mode():
	get_parent().junction_mirroring_off()
	get_parent().rotate_junctions()

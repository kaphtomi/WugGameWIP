extends Node

const STARTING_FOCUS_PERIOD = 9  #The initial "normal mode" time in seconds
const STARTING_SLEEP_PERIOD = 10  #The initial "hard mode" time in seconds
const STARTING_CALM_PERIOD = 30  #The initial "easy mode" time in seconds
const STATE_CHANGE_DELTA = 5 #Increments the states period by 5 seconds

var current_state
var schedule = {
	GlobalVariables.WUG_STATE.FOCUS:STARTING_FOCUS_PERIOD, 
	GlobalVariables.WUG_STATE.CALM:STARTING_CALM_PERIOD, 
	GlobalVariables.WUG_STATE.SLEEP:STARTING_SLEEP_PERIOD
}  #Normal, Easy, and Hard modes, with their respective times

# Called when the node enters the scene tree for the first time.
func _ready():
	current_state = GlobalVariables.WUG_STATE.FOCUS
	GlobalVariables.cur_state=current_state
	$SleepTimer.start(STARTING_FOCUS_PERIOD)


func _on_sleep_timer_timeout():
	change_states()
	$SleepTimer.start(schedule[current_state])


func change_states():
	update_state_periods(current_state)
	# For now just moves to the next state, but this can definitely be improved
	if current_state == GlobalVariables.WUG_STATE.FOCUS:
		current_state = GlobalVariables.WUG_STATE.SLEEP
	elif current_state == GlobalVariables.WUG_STATE.SLEEP:
		current_state = GlobalVariables.WUG_STATE.CALM
	else:
		current_state = GlobalVariables.WUG_STATE.FOCUS
	GlobalVariables.cur_state=current_state

func update_state_periods(old_state):
	if old_state == GlobalVariables.WUG_STATE.SLEEP:
		schedule[old_state] += STATE_CHANGE_DELTA
	elif schedule[old_state] > STATE_CHANGE_DELTA:
		schedule[old_state] -= STATE_CHANGE_DELTA

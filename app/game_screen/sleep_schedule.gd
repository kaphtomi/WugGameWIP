extends Node

const STARTING_AWAKE_PERIOD = 90  #The initial "normal mode" time in seconds
const STARTING_SLEEPING_PERIOD = 10  #The initial "hard mode" time in seconds
const STARTING_CALM_PERIOD = 30  #The initial "easy mode" time in seconds
const STATE_CHANGE_DELTA = 5 #

var current_state
var schedule = {
	"Awake":STARTING_AWAKE_PERIOD, 
	"Calm":STARTING_CALM_PERIOD, 
	"Sleeping":STARTING_SLEEPING_PERIOD
}  #Normal, Easy, and Hard modes, with their respective times

# Called when the node enters the scene tree for the first time.
func _ready():
	current_state = "Awake"
	$TestLabel.text = "Current Mode: " + current_state
	$SleepTimer.start(STARTING_AWAKE_PERIOD)


func _on_sleep_timer_timeout():
	change_states()
	$Timer.start(schedule[current_state])


func change_states():
	update_state_periods(current_state)
	# For now just moves to the next state, but this can definitely be improved
	if current_state == "Awake":
		current_state = "Sleeping"
	elif current_state == "Sleeping":
		current_state = "Calm"
	else:
		current_state = "Awake"
	$TestLabel.text = "Current Mode: " + current_state

func update_state_periods(old_state):
	if old_state == "Sleeping":
		schedule[old_state] = schedule[old_state] + STATE_CHANGE_DELTA
	
	if schedule[old_state] > STATE_CHANGE_DELTA:
		schedule[old_state] = schedule[old_state] - STATE_CHANGE_DELTA

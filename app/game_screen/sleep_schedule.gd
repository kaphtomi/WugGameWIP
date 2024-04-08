extends Node

var current_state
var schedule = ["Awake", "Calm", "Sleeping"]  #Normal, Easy, and Hard modes

const STARTING_AWAKE_PERIOD = 90  #The initial "normal mode" time in seconds
const STARTING_SLEEPING_PERIOD = 10  #The initial "hard mode" time in seconds
const STARTING_CALM_PERIOD = 30  #The initial "easy mode" time in seconds

# Called when the node enters the scene tree for the first time.
func _ready():
	current_state = "Awake"
	$SleepTimer.wait_time = STARTING_AWAKE_PERIOD
	$SleepTimer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _on_sleep_timer_timeout():
	pass # Replace with function body.

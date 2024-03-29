extends Control

signal time_up

var current_seconds = 0
var current_minutes = 0
const MAX_SECONDS = 30
const MAX_MINUTES = 1
const ONE_SECOND = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	z_index = 0  #Makes the timer get drawn in the background
	reset_timer()
	$TimeRemaining.text = str(current_minutes)+ ":" + str(current_seconds)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func reset_timer():
	current_seconds = MAX_SECONDS
	current_minutes = MAX_MINUTES


func _on_time_keeper_timeout():
	if current_seconds == 0:
		if current_minutes > 0:
			current_minutes-= 1
			current_seconds = 60
		else:
			current_minutes = 0
			current_seconds = 1
			time_up.emit()
			$Timer.stop()
	current_seconds -= ONE_SECOND
	
	if current_seconds < 10: #formats the seconds
		$TimeRemaining.text = str(current_minutes)+ ":0" + str(current_seconds)
	else:
		$TimeRemaining.text = str(current_minutes)+ ":" + str(current_seconds)


func _on_blackboard_start_timer():
	$Timer.start(ONE_SECOND)
	pass # Replace with function body.

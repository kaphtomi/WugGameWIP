extends Control

var seconds = 0
var minutes = 0
var Dseconds = 30
var Dminutes = 1
# Called when the node enters the scene tree for the first time.
func _ready():
	Reset_Timer()
	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	$TimeRemaining.text = str(minutes)+ ": " + str(seconds)
	#$TimeRemaining.text = "%s" % $Timer.time_left
	#$TimeRemaining.text = String(minutes)+ ": " + String(seconds)
	pass

func _on_timer_timeout():
	if seconds == 0:
		if minutes > 0:
			minutes-=1
			seconds = 60
	seconds -=1
	#$TimeRemaining.text = "%s" % $Timer.time_left
	#$TimeRemaining.text = str(minutes)+ ": " + str(seconds)
	pass # Replace with function body.



func Reset_Timer():
	seconds = Dseconds
	minutes = Dminutes

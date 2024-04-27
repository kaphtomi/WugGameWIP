extends Line2D
var start
var end
var direction = false
var time_in = 0.0
var time_out = 0.0
var ending = false
var shrinking = false
var happy = false
var happiness = 0 #happiness :) (amount to knock the junction by in the submitted path)
var ended = false
var DURATION = .33
var type
var start_offset
var end_offset 



# Called when the node enters the scene tree for the first time.
func _ready():
	start = Vector2.ZERO
	end = Vector2.ZERO
	start_offset = Vector2.ZERO
	end_offset = Vector2.ZERO
	sketch()
	pass

#pop ins are done automatically based on process, but this is used to color it appropriately
#and determine how it interacts with the logic in wire
func pop_in_path():
	set_type(GlobalVariables.HighlightState.PATH)

func pop_in_potential():
	set_type(GlobalVariables.HighlightState.POTENTIAL)

#updates its position and length according to the time variables that are updated accordingly
#in process
func update():
	var s = start + start_offset+(end+end_offset-start-start_offset)*sqrt(time_out)
	var e = start + start_offset+(end+end_offset-start-start_offset)*sqrt(time_in)
	if direction:
		var m = s
		s = e
		e = m
	set_point_position(0,s)
	set_point_position(1,e)

#these all make time_out increase,
#and determine direction

#shrinks out into the outgoing junction
func pop_out():
	ending = true
	
#shrinks back into the incoming junction
func shrink_out():
	shrinking = true
	
#shrinks out into the outgoing junction, faster and yellow
func happy_out():
	happy = true
	color()

#sets the type and colors accordingly
func set_type(new_type):
	type=new_type
	color()

#perhaps we should use a boolean like in wire but i don't think it's needed
#since the color rarely updates
func set_red():
	modulate = GlobalVariables.red_color
	
func unset_red():
	color()

func color():
	if type == GlobalVariables.HighlightState.PATH:
		modulate = GlobalVariables.path_color
	if type == GlobalVariables.HighlightState.POTENTIAL:
		modulate = GlobalVariables.potential_color
	if happy:
		modulate = Color.GOLD

# updates start, end, and the time_in / time_out vars which are used in the animations
func _process(delta):
	if direction:
		end = get_parent().start_pos
		start = get_parent().end_pos
	else:
		start = get_parent().start_pos
		end = get_parent().end_pos
	var d = (end-start).normalized()*70
	end -= d
	start += d
	time_in += delta / DURATION
	time_in = clamp(time_in,0.0,1.0)
	if shrinking:
		time_in -= 2*delta / DURATION
		if time_in <0:
			ended=true
			clamp(time_in,0.0,1.0)
	if ending:
		time_out += 2*delta / DURATION
		if happy:
			time_out += 2*delta/DURATION
		if time_out-time_in>0.0:
			ended = true
			clamp(time_out,0.0,1.0)
	update()
	
func sketch():
	end_offset = end_offset * .5 + 3 * Vector2.ONE.rotated(randf()*TAU)
	start_offset = start_offset * .5 + 3 * Vector2.ONE.rotated(randf()*TAU)
	

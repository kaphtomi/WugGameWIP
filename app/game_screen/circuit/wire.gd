extends AnimatableBody2D

const Highlight = preload("res://app/game_screen/circuit/highlight.tscn")
var _from
var _to
var hue = randf()
var sat = 1
var done = 0.0
var connecting_letters: Array[String] = []
var thickness: float = 1
const WIDTH_SCALE: int = 3
const MAX_THICKNESS: int = 7
var not_scored = true
var red = false

var highlights = [] #a list of highlights

var block_decay = false


var time = 0
var start_pos = Vector2.ZERO
var end_pos = Vector2.ZERO
var start_offset = Vector2.ZERO
var end_offset = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	thickness = randi() % 4 + 4
	color()

func set_nodes(from, to):
	_from = from
	_to = to
	start_pos = from.position
	end_pos = to.position
	from.add_outgoing(self)
	to.add_incoming(self)
	connecting_letters.append(_from.get_letter())
	connecting_letters.append(_to.get_letter())
	update()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	start_pos = _from.position
	end_pos = _to.position
	time += _delta
	color()
	update()
	for h in highlights.duplicate(): #only look at highlights
		if h.ended:
			highlights.erase(h)
			h.queue_free()

const SKETCHY_WIRES: bool = true

func sketch():
	start_offset = start_offset*.5 + 5*Vector2.ONE.rotated(randf()*TAU)
	end_offset = end_offset*.5 + 5*Vector2.ONE.rotated(randf()*TAU)
	for h in highlights: #just realized this doesn't resketch the submitted path, this is probably find though, would be too much work
		h.sketch()

func update():
	visible = true
	var d = end_pos - start_pos
	if d.length() < 160:
		visible = false
	var e = end_pos+end_offset - d.normalized()*70
	var s = start_pos+start_offset + d.normalized()*70
	$Stroke.width = clamp(thickness * WIDTH_SCALE, 5, 20)
	$Stroke.set_point_position(0,s)
	$Stroke.set_point_position(1,s+(e-s)*done)
	
func color():
	$Stroke.set_default_color(get_color())

#handles the reddening
func get_color():
	if red:
		return GlobalVariables.red_color
	else:
		return Color.from_ok_hsl(hue, sat, .5 + thickness*.03)
	
func pop_in(t:float):
	done = t

#path highlight, called by circuit
func highlight_path(inverted: bool = false):
	var h = Highlight.instantiate()
	h.direction = inverted
	add_child(h)
	h.pop_in_path()
	highlights.append(h)

#used by highlight
func get_start_pos():
	var start = _from.position
	var end = _to.position
	var s = end - start
	return start + s.normalized()*70

#used by highlight, honestly a bit silly but computer is fast and it's not worth breaking when
#i could be working on a scores graph
func get_end_pos():
	var start = _from.position
	var end = _to.position
	var s = end - start
	return end - s.normalized()*70

#potential highlight, called by circuit
func highlight_potential(inverted: bool = false):
	var h = Highlight.instantiate()
	h.direction=inverted
	add_child(h)
	h.pop_in_potential()
	highlights.append(h)
	
#makes the initial red more intense
func flash_red():
	var tween = create_tween()
	tween.tween_property(self,"modulate",Color(1.0,0.0,0.0),.1)
	tween.tween_property(self,"modulate",Color(1.0,1.0,1.0),.1)
	tween.play()

#sets it to red
func set_red():
	red = true
	flash_red()
	for h in highlights:
		h.set_red()

#unsets red
func unset_red():
	red = false
	for h in highlights:
		h.unset_red()
		
#clears all highlights not in submitted path
func clear_highlights():
	for h in highlights:
		h.queue_free()
	highlights=[]
	
#removes a specific highlight, but i don't think i ended up using it
#TODO see if this can be removed
func remove_highlight(h):
	highlights.erase(h)
	
#clears all potential highlights with a fun animation
func clear_potential_highlight():
	for h in highlights:
		if h.type == GlobalVariables.HighlightState.POTENTIAL:
			h.pop_out()
	
#clears all path highlights with a fun animation
func clear_path_highlight():
	for h in highlights:
		if h.type == GlobalVariables.HighlightState.PATH:
			h.shrink_out()

#removes all path highlights and returns them for the submitted path
#TODO investigate if this could run into a strange thing with the above
#method?
func path_to_higherlights():
	for h in highlights.duplicate():
		if h.type == GlobalVariables.HighlightState.PATH:
			highlights.erase(h)
			return h

func get_start():
	return _from

func get_end():
	return _to
	
func get_thickness():
	return thickness
	
func set_thickness(width: float):
	thickness = width
	
func decay(delta, score):
	#if block_decay: return
	var decrement = delta*.01*randf()*sqrt(score)
	if not_scored:
		decrement*=1.5
	if GlobalVariables.cur_dif==GlobalVariables.WUG_DIFF.HARD:
		decrement*=log(score+1)/2
	if GlobalVariables.cur_dif==GlobalVariables.WUG_DIFF.MED:
		decrement*=2
	thickness -= decrement
	if thickness< 0:
		return true
	return false
	
func increment_thickness():
	thickness +=1
	if !not_scored:
		thickness+=1
	thickness = min(thickness,MAX_THICKNESS)
	
func decrement_thickness():
	if thickness > 1:
		thickness -= 1
	pass

func check_connecting_letters(letter1: String, letter2: String):
	if connecting_letters.has(letter1) && connecting_letters.has(letter2) && letter1!=letter2:
		return true
	return false

func snap():
	_from.remove_outgoing(self)
	_to.remove_incoming(self)

#increases score of wire first time it's used, and also is used
#the not_scored thing makes the wire decay faster until it's used for
#the first time, and also, once it's scored for the first time, it
#then increments faster
func score_wire():
	var s = not_scored
	not_scored = false
	return s

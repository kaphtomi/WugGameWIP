extends AnimatableBody2D

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

var highlight_tween
var highlight_state = HighlightState.NONE

enum HighlightState { NONE, BLUE, GREEN, YELLOW, RED }
	

# Called when the node enters the scene tree for the first time.
func _ready():
	thickness = randi() % 4 + 4
	color()

func set_nodes(from, to):
	_from = from
	_to = to
	var start = from.position
	var end = to.position
	from.add_outgoing(self)
	to.add_incoming(self)
	connecting_letters.append(_from.get_letter())
	connecting_letters.append(_to.get_letter())
	update(start,end)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	color()
	if (done>.99):
		update(_from.position, _to.position)
	pass
	
func update(start: Vector2, end: Vector2):
	$Stroke.width = clamp(thickness * WIDTH_SCALE, 5, 20)
	$Stroke.set_point_position(0,start)
	$Stroke.set_point_position(1,end)
	$HighlightStroke.width = clamp(thickness * WIDTH_SCALE, 5, 20)
	if highlight_tween and not highlight_tween.is_running():
		$HighlightStroke.set_point_position(0,start)
		$HighlightStroke.set_point_position(1,end)
	
func color():
	$Stroke.set_default_color(Color.from_ok_hsl(hue, sat, .5 + thickness*.03))

func get_color():
	return Color.from_ok_hsl(hue, sat, .5 + thickness*.03)
	
func pop_in(t:float):
	update(_from.position, _from.position+ t*(_to.position-_from.position))
	done = t

func fade_highlight_stroke(t: float, from, to):
	var current_origin: Vector2 = from.position
	var current_dest: Vector2 = to.position
	var new_end_pos = (current_dest - current_origin) * t + current_origin
	$HighlightStroke.set_point_position(0, current_origin)
	$HighlightStroke.set_point_position(1, new_end_pos)

func set_highlight_stroke_length(t: float):
	fade_highlight_stroke(t, _from, _to)
	
func set_highlight_stroke_length_inverted(t: float):
	fade_highlight_stroke(t, _to, _from)

func highlight(color: Color, state: HighlightState, inverted: bool = false):
	if highlight_state == state: return
	$HighlightStroke.set_default_color(color) # place so early in code to enable immediate return if already highlighted
	if highlight_state != HighlightState.NONE: 
		#$HighlightStroke.set_visible(false)
		#$HighlightStroke.set_visible(true)
		highlight_state = state
		
		return
	
	highlight_state = state
	highlight_tween = create_tween()
	if inverted: highlight_tween.tween_method(set_highlight_stroke_length_inverted, 0.0, 1.0, 0.5)
	else: highlight_tween.tween_method(set_highlight_stroke_length, 0.0, 1.0, 0.5)
	$HighlightStroke.set_visible(true)
	highlight_tween.play()

func highlight_blue(inverted: bool = false):
	highlight(Color.BLUE, HighlightState.BLUE, inverted)

func highlight_green(inverted: bool = false):
	print("GREEEEEN")
	highlight(Color.GREEN, HighlightState.GREEN, inverted)

func flash_num_helper(t: float):
	if t < 0.33: return t * 3
	elif t < 0.67: return 1
	elif t > 0.67: return 1 - (t - 0.67) * 3

func tween_highlight_color(t: float, og_color: Color, target_color: Color):
	var r = og_color.r * (1 - t) + target_color.r * (t)
	var g = og_color.g * (1 - t) + target_color.r * (t)
	var b = og_color.b * (1 - t) + target_color.r * (t)
	$HighlightStroke.set_default_color(r, g, b)

func flash_red():
	if highlight_state == HighlightState.RED: return
	var og_color = $HighlightStroke.color
	highlight_tween = create_tween()
	highlight_tween.tween_method(func flash_red_tween_helper(t: float):
		t = flash_num_helper(t)
		tween_highlight_color(t, og_color, Color.RED), 0.0, 1.0, 0.5)
		
func clear_highlight(unless: HighlightState = HighlightState.NONE):
	if highlight_state == unless: return
	$HighlightStroke.set_visible(false)
	highlight_state = HighlightState.NONE

func get_start():
	return _from

func get_end():
	return _to
	
func get_thickness():
	return thickness
	
func set_thickness(width: float):
	thickness = width
	
func decay(delta, score):
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

func score_wire():
	var s = not_scored
	not_scored = false
	return s

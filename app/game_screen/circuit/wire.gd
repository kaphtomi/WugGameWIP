extends AnimatableBody2D

var _from
var _to
var done = 0.0
var connecting_letters: Array[String] = []
var thickness: float = 1
const WIDTH_SCALE: int = 3
const MAX_THICKNESS: int = 7
const HIGHLIGHT_DURATION = .2
var not_scored = true

var block_decay = false




#region logic
func _ready():
	thickness = randi() % 4 + 4
	color()

func set_nodes(from, to):
	_from = from
	_to = to
	from.add_outgoing(self)
	to.add_incoming(self)
	connecting_letters.append(_from.get_letter())
	connecting_letters.append(_to.get_letter())
	update_ends()
	update_stroke()

func _process(_delta):
	if highlighted:
		highlight_amount = min(highlight_amount +_delta/HIGHLIGHT_DURATION,1.0)
	color()
	color_highlight()
	update_ends()
	update_stroke()
	update_highlight()
	pass
#endregion


#region draw
var start
var end
var s

func update_ends():
	start = _from.position
	end = _to.position
	s = end - start
	visible = done*s.length() > 160
	s -= s.normalized()*140
	end -= s.normalized()*70
	start += s.normalized()*70

func update_stroke():
	var start_stroke = start
	var end_stroke = start + done*s
	$Stroke.width = clamp(thickness * WIDTH_SCALE, 5, 20)
	$Stroke.set_point_position(0, start_stroke + start_offset)
	$Stroke.set_point_position(1, end_stroke + end_offset)

func pop_in(t:float):
	done = t

func update_highlight():
	$HighlightStroke.visible = highlighted
	var start_highlight = start
	var end_highlight = start + highlight_amount*s
	if highlight_reverse:
		start_highlight = end - highlight_amount*s
		end_highlight = end
	$HighlightStroke.width = clamp(thickness * WIDTH_SCALE, 5, 20)
	$HighlightStroke.set_point_position(0, start_highlight + start_offset + start_offset_h)
	$HighlightStroke.set_point_position(1, end_highlight + end_offset + end_offset_h)

#endregion		


#region color
var hue = randf()
var sat = 1
var red_amount=0

func color():
	$Stroke.set_default_color(lerp(get_color(), GlobalVariables.color_invalid, sin(red_amount)))

func get_color():
	return Color.from_ok_hsl(hue, sat, .5 + thickness*.03)

func color_highlight():
	$HighlightStroke.set_default_color(lerp(get_highlight_color(), GlobalVariables.color_invalid,sin(red_amount)))

func get_highlight_color():
	var hl_color = Color.WHITE
	match hl:
		highlight_type.NONE:
			hl_color = GlobalVariables.color_none
		highlight_type.VALID:
			hl_color = GlobalVariables.color_valid
		highlight_type.POTENTIAL:
			hl_color = GlobalVariables.color_potential
	return hl_color
#endregion

enum highlight_type {NONE, POTENTIAL, VALID}
var hl = highlight_type.NONE
var highlighted = false
var highlight_reverse = false
var highlight_amount = 0

func highlight(to):
	if highlighted:
		return
	if to==_to:
		highlight_reverse = false
	else:
		highlight_reverse = true
	highlighted = true


func potential_highlight(to):
	highlight(to)
	hl = highlight_type.POTENTIAL

func valid_highlight(to):
	highlight(to)
	hl = highlight_type.VALID

func clear_highlight():
	highlighted = false
	highlight_reverse = false
	highlight_amount = 0
	hl = highlight_type.NONE

func flash_red():
	red_amount = 0
	var tween = create_tween()
	tween.tween_property(self,"red_amount",PI,.5)
	tween.play()
	

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

func other(junc):
	if junc == _to:
		return _from
	if junc == _from:
		return _to

func snap():
	_from.remove_outgoing(self)
	_to.remove_incoming(self)

func score_wire():
	var s = not_scored
	not_scored = false
	return s
	
#region sketch
var start_offset = Vector2.ZERO
var end_offset = Vector2.ZERO
var start_offset_h = Vector2.ZERO
var end_offset_h = Vector2.ZERO

const SKETCHY_WIRES: bool = true

func sketch():
	start_offset = start_offset*.5 + 5*Vector2.ONE.rotated(randf()*TAU)
	end_offset = end_offset*.5 + 5*Vector2.ONE.rotated(randf()*TAU)
	start_offset_h = start_offset_h *.5 + 3*Vector2.ONE.rotated(randf()*TAU)
	end_offset_h = end_offset_h*.5 + 3*Vector2.ONE.rotated(randf()*TAU)
#endregion

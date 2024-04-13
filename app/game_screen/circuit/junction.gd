extends Area2D
# Called when the node enters the scene tree for the first time.
var outgoing_edges : Array
var incoming_edges : Array
var velocity : Vector2
var size : Vector2
var _letter: String = ""
var popped_in = false

enum HighlightState { NONE, POTENTIAL, SELECTED, INVALID }
var highlight_state = HighlightState.NONE

func _ready():
	velocity = Vector2.ZERO

func has_incoming():
	return incoming_edges.size() > 0

func has_outgoing():
	return incoming_edges.size() > 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	velocity *= exp(-_delta*velocity.length_squared()*.0001)
	
func move(vee):
	position += vee
	
func get_outgoing_edges():
	return outgoing_edges
	
func get_incoming_edges():
	return incoming_edges
	
func get_connections():
	var connections = {}
	for w in outgoing_edges:
		connections[w.get_end()]=true
	for w in incoming_edges:
		connections[w.get_start()]=true
	return connections
	
func add_outgoing(to):
	outgoing_edges.append(to)
	
func add_incoming(from):
	incoming_edges.append(from)
	
func remove_outgoing(to):
	outgoing_edges.remove_at(outgoing_edges.find(to))

func remove_incoming(from):
	incoming_edges.remove_at(incoming_edges.find(from))
	
func set_letter(letter):
	$Letter.text = letter
	_letter = letter
	
func get_letter():
	return _letter

func pop_in_wires():
	popped_in = true
	for e in outgoing_edges:
		pop_in_wire(e)
	
func pop_in_wire(e):
	e.pop_in(0)
	var tween = create_tween()
	tween.tween_method(e.pop_in,0.0,1.0,.3+.1*randf())
	tween.play()
	
func force(amt : Vector2):
	velocity += amt
	
func get_velocity():
	return velocity

func highlight_valid(amt: float):
	$Letter.set("theme_override_colors/font_color", Color(amt, 1.0, amt))

func highlight_potential(amt: float):
	$Letter.set("theme_override_colors/font_color", Color(amt, amt, 1.0))

func cos_0_to_15(val: float):
	var ret = cos(val*2*PI) + 1
	return ret * (2/3)
	
func apply_equal_scale(t: float):
	set_scale(Vector2(t, t))
	
func pulse():
	var tween = create_tween()
	var tween2 = create_tween()
	tween2.tween_method(apply_equal_scale, 1.5, 1.0, 0.25)
	
	tween.tween_method(apply_equal_scale, 1.0, 1.5, 0.25)
	tween.tween_callback(tween2.play)
	tween.play()
	
func flash_num_helper(t: float):
	if t < 0.33: return t * 3
	elif t < 0.67: return 1
	elif t > 0.67: return 1 - (t - 0.67) * 3

func tween_highlight_color(t: float, og_color: Color, target_color: Color):
	var r = og_color.r * (1 - t) + t
	var g = og_color.g * (1 - t)
	var b = og_color.b * (1 - t)
	$Letter.set("theme_override_colors/font_color", Color(r, g, b))

func flash_red():
	if highlight_state == HighlightState.INVALID: return
	var og_state = highlight_state
	highlight_state = HighlightState.INVALID
	var tween = create_tween()
	var reset = func reset(): highlight_state = og_state; tween.kill()
	var og_color = $Letter.get("theme_override_colors/font_color")
	
	tween.tween_method(func flash_red_tween_helper(t: float):
		t = flash_num_helper(t)
		tween_highlight_color(t, og_color, Color.RED), 0.0, 1.0, 0.5)
	tween.tween_callback(reset)
	tween.play()
	#pulse()

func set_selected():
	if highlight_state == HighlightState.SELECTED: return
	highlight_state = HighlightState.SELECTED
	var tween = create_tween()
	tween.tween_method(highlight_valid, 1.0, 0.0, 0.1)
	tween.play()
	pulse()

func set_potential():
	if highlight_state == HighlightState.POTENTIAL: return
	highlight_state = HighlightState.POTENTIAL
	var tween = create_tween()
	tween.tween_method(highlight_potential, 1.0, 0.0, 0.1)
	tween.play()
	pulse()

func clear_highlight():
	$Letter.set("theme_override_colors/font_color", Color.WHITE)
	highlight_state = HighlightState.NONE

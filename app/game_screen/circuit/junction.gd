extends Area2D
# Called when the node enters the scene tree for the first time.
var outgoing_edges : Array
var incoming_edges : Array
var velocity : Vector2
var size : Vector2
var _letter: String = ""
var popped_in = false
var time = 0
var offset = Vector2.ZERO
var letter_center

var highlight_tween: Tween

enum HighlightState { NONE, POTENTIAL, SELECTED, INVALID }
var highlight_state = HighlightState.NONE

func _ready():
	velocity = Vector2.ZERO
	letter_center = $Letter.position
	encircle()
	$Letter.modulate = Color.BLACK
	$circler.modulate = Color.BLACK

func has_incoming():
	return incoming_edges.size() > 0

func has_outgoing():
	return incoming_edges.size() > 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	velocity *= exp(-_delta*velocity.length_squared()*.0001)
	if highlight_state == HighlightState.NONE:
		clear_highlight()

func sketch():
	offset = offset*.5 + 3*Vector2.ONE.rotated(randf()*TAU)*randf()
	$Letter.position = letter_center + offset
	encircle()
	
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
	$Letter.modulate = Color(1, .46, 0.78)

func highlight_potential(amt: float):
	$Letter.modulate = Color(1 - 0.5216 * amt, 1 - 0.1926 * amt, 1.0)

func cos_0_to_15(val: float):
	var ret = cos(val*2*PI) + 1
	return ret * (2/3)
	
func apply_equal_scale(t: float):
	set_scale(Vector2(t, t))
	
func pulse():
	var tween = create_tween()
	var tween2 = create_tween()
	tween.tween_method(apply_equal_scale, 1.0, 1.5, 0.167)
	tween2.tween_method(apply_equal_scale, 1.5, 1.0, 0.25)
	tween.tween_callback(tween2.play)
	tween.play()

func de_pulse():
	var tween = create_tween()
	tween.tween_method(apply_equal_scale, 1.5, 1.0, 0.25)
	tween.play()
	
	
func flash_num_helper(t: float):
	if t < 0.33: return t * 3
	elif t < 0.67: return 1
	elif t > 0.67: return 1 - (t - 0.67) * 3

func tween_highlight_color(t: float, og_color: Color, target_color: Color):
	var r = og_color.r * (1 - t) + t
	var g = og_color.g * (1 - t)
	var b = og_color.b * (1 - t)
	$Letter.modulate = Color(r, g, b)

func flash_red(revert: bool = true):
	if highlight_state == HighlightState.INVALID: return
	var og_state = highlight_state
	highlight_state = HighlightState.INVALID
	highlight_tween = create_tween()
	var reset
	if revert:
		reset = func reset(): 
			highlight_state = og_state
			match highlight_state:
				HighlightState.POTENTIAL: highlight_potential(1.0)
				HighlightState.SELECTED: highlight_valid(1.0)
	else:
		reset = clear_highlight
	var og_color = $Letter.modulate
	
	highlight_tween.tween_method(func flash_red_tween_helper(t: float):
		t = flash_num_helper(t)
		tween_highlight_color(t, og_color, Color.RED), 0.0, 1.0, 0.5)
	highlight_tween.tween_callback(reset)
	highlight_tween.play()
	pulse()

func pulse_and_reset():
	clear_highlight()
	pulse()

func set_selected():
	if highlight_state == HighlightState.SELECTED: return
	highlight_state = HighlightState.SELECTED
	highlight_tween = create_tween()
	highlight_tween.tween_method(highlight_valid, 0.0, 1.0, 0.1)
	highlight_tween.play()
	pulse()

func set_potential():
	if highlight_state == HighlightState.POTENTIAL: return
	highlight_state = HighlightState.POTENTIAL
	highlight_tween = create_tween()
	highlight_tween.tween_method(highlight_potential, 0.0, 1.0, 0.1)
	highlight_tween.play()
	pulse()

func clear_highlight():
	highlight_state = HighlightState.NONE
	if highlight_tween != null and highlight_tween.is_running():
		highlight_tween.kill()
	$Letter.modulate = Color.WHITE
	$circler.modulate = Color.BLACK

func encircle():
	var circle_start = randf()*TAU
	var num_points = 20
	var thetas = []
	var total = 0
	for i in num_points:
		var theta = .1 + randf()
		total+=theta
		thetas.append(total)
	var scale_factor = TAU/total
	var vector_array = PackedVector2Array()
	var sum = Vector2.ZERO
	for i in thetas.size():
		var theta = thetas[i]
		var vector = Vector2.ONE.rotated(theta*scale_factor+circle_start)*(42.5+5*randf())-sum
		sum += vector
		vector_array.append(sum)
	$circler.polygon = vector_array
	pass

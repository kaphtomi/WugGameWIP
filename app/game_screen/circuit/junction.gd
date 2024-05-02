extends Area2D
# Called when the node enters the scene tree for the first time.
var outgoing_edges : Array
var incoming_edges : Array
var velocity : Vector2
var pulse_amt = 1.0
var size = 1.0
var cur_size = 1.0
var _letter: String = ""
var popped_in = false
var time = 0
var offset = Vector2.ZERO
var letter_center
var red = false
var affected = false
var is_mirrored = false
var current_letter_rotation = 0
const AFFECTED_SIZE = 1.1

var highlight_state = GlobalVariables.HighlightState.NONE

func _ready():
	velocity = Vector2.ZERO
	letter_center = $Letter.position
	$Letter.pivot_offset = $Letter.size/2
	encircle()
	$circler.modulate = Color.BLACK

func has_incoming():
	return incoming_edges.size() > 0

func has_outgoing():
	return incoming_edges.size() > 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	velocity *= exp(-_delta*velocity.length_squared()*.0001)
	if popped_in:
		size_junc(_delta)
		
#sizes the junction. Starts based on the pulse_amt, which ranges from 1 to 1.2
#then if it's the selected junction (highlightstate path), it scales that by 1.5
#then if it's currently in the path (affected), it scales that by 1.1
#the sizing is a lerp thing so size represents the size it's moving towards
#and cur_size is the current size. This way we can have a lot of things that
#affect sizing without worrying about tween concurrency issues
#TODO check to see if affected can break
func size_junc(delta):
	size = pulse_amt
	if highlight_state == GlobalVariables.HighlightState.PATH:
		size *= 1.5
	if affected:
		size *= 1.1
	cur_size = lerp(cur_size,size,delta*10.0)
	set_scale(Vector2.ONE*cur_size)
	
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

func color():
	$Letter.modulate = Color.WHITE
	if highlight_state==GlobalVariables.HighlightState.PATH:
		$Letter.modulate = GlobalVariables.path_color
	if highlight_state==GlobalVariables.HighlightState.POTENTIAL:
		$Letter.modulate = GlobalVariables.potential_color
	if red:
		$Letter.modulate =GlobalVariables.red_color

#pulse amt is a property that basically represents the base amount of scaling
func pulse():
	var tween = create_tween()
	tween.tween_property(self,"pulse_amt",1.2,.2)
	tween.tween_property(self,"pulse_amt",1.0,.2)
	tween.play()

#all these are fairly self explanatory
func flash_red(_revert: bool = true):
	var tween = create_tween()
	tween.tween_property(self,"modulate",Color(1.0,0.0,0.0),.1)
	tween.tween_property(self,"modulate",Color(1.0,1.0,1.0),.1)
	tween.play()
	pulse()


func pulse_and_reset():
	clear_highlight()
	pulse()


func set_red():
	red = true
	flash_red()
	color()

func unset_red():
	red = false
	color()

func set_selected():
	highlight_state = GlobalVariables.HighlightState.PATH
	affected = true
	color()
	pulse()

func set_potential():
	highlight_state = GlobalVariables.HighlightState.POTENTIAL
	color()
	pulse()

func deselect():
	highlight_state = GlobalVariables.HighlightState.NONE
	affected = false
	color()

func clear_highlight():
	highlight_state = GlobalVariables.HighlightState.NONE
	affected = false
	color()

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

func toggle_mirror():
	$Letter.scale *= -1

func mirror_on():
	if !is_mirrored:
		toggle_mirror()
		is_mirrored = true

func mirror_off():
	if is_mirrored:
		toggle_mirror()
		is_mirrored = false

func random_rotation():
	var random_rotation_degrees = randi() % 270 + 90
	current_letter_rotation = random_rotation_degrees
	return random_rotation_degrees

func set_junction_rotation(degrees):
	$Letter.set_rotation_degrees(degrees)
	current_letter_rotation = degrees

func get_current_rotation():
	return current_letter_rotation

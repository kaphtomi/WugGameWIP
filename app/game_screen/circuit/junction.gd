extends Area2D
# Called when the node enters the scene tree for the first time.
var outgoing_edges : Array
var incoming_edges : Array
var velocity : Vector2
var size : Vector2
var _letter: String = ""
var popped_in = false

func _ready():
	velocity = Vector2.ZERO

func has_incoming():
	return incoming_edges.size() > 0

func has_outgoing():
	return incoming_edges.size() > 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	velocity *= exp(-_delta*velocity.length_squared()*.001)
	
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

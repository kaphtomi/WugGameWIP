extends Area2D
# Called when the node enters the scene tree for the first time.
var outgoing_edges : Array
var incoming_edges : Array
var velocity : Vector2
var size : Vector2
var letter: String = ""

var is_start_node = false
var is_end_node = false
var has_physics = true

func _ready():
	velocity = Vector2.ZERO

func make_start_node():
	is_start_node = true
	has_physics = false
	
func make_end_node():
	is_end_node = true
	has_physics = false

func is_a_start_node():
	return is_start_node
	
func is_a_end_node():
	return is_end_node

func has_incoming():
	return incoming_edges.size() > 0

func has_outgoing():
	return incoming_edges.size() > 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if has_physics:
		velocity *= exp(-_delta*2)
	
func get_outgoing_edges():
	return outgoing_edges
	
func get_incoming_edges():
	return incoming_edges
	
func add_outgoing(to):
	outgoing_edges.append(to)
	
func add_incoming(from):
	incoming_edges.append(from)
	
func remove_outgoing(to):
	outgoing_edges.remove_at(outgoing_edges.find(to))

func remove_incoming(from):
	incoming_edges.remove_at(incoming_edges.find(from))
	
func change_text(text):
	$Letter.text = text
	letter = text

func pop_in_edges():
	for e in outgoing_edges:
		pop_in_edge(e)
	
func pop_in_edge(e):
	e.pop_in(0)	
	var tween = create_tween()
	tween.tween_method(e.pop_in,0.0,1.0,.3+.1*randf())
	tween.play()
	
func force(amt : Vector2):
	if has_physics:
		velocity += amt
	
func get_velocity():
	return velocity

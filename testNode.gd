extends Area2D
# Called when the node enters the scene tree for the first time.
var outgoing_edges : Array
var incoming_edges : Array
var velocity : Vector2
var size : Vector2
var letter: String = ""

func _ready():
	velocity = Vector2.ZERO


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	velocity *= exp(-_delta)
	
func get_outgoing_edges():
	return outgoing_edges
	
func get_incoming_edges():
	return incoming_edges
	
func add_outgoing(to):
	outgoing_edges.append(to)
	
func add_incoming(from):
	incoming_edges.append(from)
	
func change_text(text):
	$Letter.text = text
	letter = text

func pop_in_edges():
	for e in outgoing_edges:
		pop_in_edge(e)
	
func pop_in_edge(e):
	e.pop_in(0)	
	var tween = create_tween()
	tween.tween_method(e.pop_in,0.0,1.0,.3)
	tween.tween_callback(e.popped_in)
	tween.play()
	
func force(amt : Vector2):
	velocity += amt
	
func get_velocity():
	return velocity

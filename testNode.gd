extends Area2D
# Called when the node enters the scene tree for the first time.
var outgoing_edges : Array
var incoming_edges : Array

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
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

func pop_in_edges():
	for e in outgoing_edges:
		pop_in_edge(e)
	
func pop_in_edge(e):
	e.pop_in(0)	
	var tween = create_tween()
	tween.tween_method(e.pop_in,0.0,1.0,.3)
	tween.play()

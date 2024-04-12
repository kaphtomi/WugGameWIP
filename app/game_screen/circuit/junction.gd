extends Area2D
# Called when the node enters the scene tree for the first time.
var outgoing_edges : Array
var incoming_edges : Array
var velocity : Vector2
var size : Vector2
var _letter: String = ""
var popped_in = false

var is_highlighted = false

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

func cos_0_to_15(val: float):
    var ret = cos(val*2*PI) + 1
    return ret * (2/3)
    
func apply_equal_scale(t: float):
    set_scale(Vector2(t, t))
    print(t)
    print(scale)
    
func pulse():
    var tween = create_tween()
    var tween2 = create_tween()
    tween2.tween_method(apply_equal_scale, 1.5, 1.0, 0.25)
    
    tween.tween_method(apply_equal_scale, 1.0, 1.5, 0.25)
    tween.tween_callback(tween2.play)
    tween.play()

func become_valid():
    if is_highlighted: return
    is_highlighted = true
    var tween = create_tween()
    tween.tween_method(highlight_valid, 1.0, 0.0, 0.1)
    tween.play()

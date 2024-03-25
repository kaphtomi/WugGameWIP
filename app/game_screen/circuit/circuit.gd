extends Control

signal decay_started

var shader_material : ShaderMaterial = ShaderMaterial.new()
var alphabetter = "etaonshrdlcumwfgypbvkjxqz".split("", true, 0)
var junctions : Array
var wires : Array
const ELECTRIC_CONSTANT : float = 3000000
const SPRING_CONSTANT : float = .1
const SPRING_LENGTH : float = 600
var score : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	shader_material.shader=load("res://assets/shader.gdshader")
	
func generate():
	generate_junctions()
	generate_wires()
	generate_animations()

func generate_junctions():
	var num_junctions : int = randi() % 3 + 10
	for i in num_junctions:
		var letter = alphabetter[randi() % alphabetter.size()]
		alphabetter.remove_at(alphabetter.find(letter))
		var vertex = Junction
		vertex.change_text(letter)
		vertex.position = Vector2(size.x * nice_rand(i,num_junctions), size.y * nice_rand(i,num_junctions))
		add_child(vertex)
		junctions.append(vertex)
		vertex.get_node("Letter").set_material(shader_material)

		
func generate_wires():
	var num_wires : int = randi() % 7 + 12
	for i in num_wires:
		var fromIndex = randi() % junctions.size()
		var toIndex = randi() % junctions.size()
		while (fromIndex == toIndex):
			toIndex = randi() % junctions.size()
		if (fromIndex > toIndex):
			var blah = toIndex
			toIndex = fromIndex
			fromIndex = blah
		var from = junctions[fromIndex]
		var to = junctions[toIndex]
		if (!wires.is_empty()):
			var continue_bool = false
			for e in wires:
				if (e.get_start()==from&&e.get_end()==to):
					continue_bool=true
			if (continue_bool):
				continue
		var edge = Wire.new()
		to.add_incoming(edge)
		from.add_outgoing(edge)
		add_child(edge)
		edge.set_nodes(from,to)
		edge.pop_in(0)
		wires.append(edge)
		edge.get_node("Stroke").set_material(shader_material)

func generate_animations():
	for i in junctions.size():
		var junction = junctions[junctions.size()-1-i]
		pop_in_vertex(junction, i)

func _process(delta):
	for i in junctions.size():
		for j in range(i,junctions.size()):
			coolombs(junctions[i],junctions[j], delta)
	for e in wires:
		if (score>5&&e.decay(delta)):
			var v1 = e.get_start()
			var v2 = e.get_end()
			var s = v2.position-v1.position
			v1.force(-s.normalized()*100)
			v2.force(s.normalized()*100)
			wires.remove_at(wires.find(e))
			e.queue_free()
			break
		hookes(e,delta)
	for v in junctions:
		border_force(v,delta)
		v.position = v.position + v.get_velocity()*delta
		v.position = Vector2(clamp(v.position.x,0,size.x),clamp(v.position.y,0,size.y))
	
#electric force
func coolombs(v1, v2, delta : float):
	var p1 : Vector2 = v1.position
	var p2 : Vector2 = v2.position
	var r : Vector2 = p2 - p1
	var f : Vector2 = ELECTRIC_CONSTANT / (r.length_squared()+1) * r.normalized()
	v1.force(-f*delta)
	v2.force(f*delta)

#spring force
func hookes(e, delta : float):
	var v1 = e.get_start()
	var v2 = e.get_end()
	var p1 : Vector2 = v1.position
	var p2 : Vector2 = v2.position
	var d : Vector2 = p2 - p1
	var s = d.length()-SPRING_LENGTH / sqrt(e.thickness) 
	var f : Vector2 = -(SPRING_CONSTANT * e.thickness * e.thickness)* s * d.normalized() * sqrt(e.done)
	v1.force(-f*delta)
	v2.force(f*delta)

#border_force
func border_force(v, delta):
	var p : Vector2 = v.position
	var k = ELECTRIC_CONSTANT
	v.force(Vector2(k*delta*(1/(p.x ** 2 + 1) - 1/((p.x-size.x) ** 2 + 1)),k*delta*(1/(p.y ** 2 + 1) - 1/((p.y-size.y) ** 2 + 1))))

#animation
func pop_in_vertex(v, i:int):
	v.scale = Vector2.ZERO
	var tween = create_tween()
	var wait = .15*i
	var dur = .25
	var callable = Callable(self, "pop_in_edges")
	callable.bind(v,wait+dur)
	tween.tween_interval(wait)
	tween.tween_property(v, "scale", (1+randf()*.3)*Vector2.ONE, dur)
	tween.tween_property(v, "scale", Vector2.ONE, randf()*.1)
	tween.tween_callback(v.pop_in_edges)
	tween.play()

# Called when text is submitted in TextField
func is_word_in_circuit(word : String):
	var letters = word.split("", false, 0)
	var update_wires : Dictionary = {}
	for i in (letters.size()-1):
		var wire = get_wire(letters[i], letters[i+1])
		if wire == null:
			return false
		update_wires[wire]=null
	for w in update_wires.keys():
		w.increment_thickness()
	score += letters.size()
	return true
		
# Gets a wire based on its start and end letter (does not depend on direction, at the moment)
func get_wire(startNodeLetter: String, endNodeLetter: String):
	for wire in wires:
		if wire.check_connecting_letters(startNodeLetter, endNodeLetter):
			return wire
	return null
	
func nice_rand(i: float, n : float):
	return .15 + .4*(i/n) +.3*randf()
	

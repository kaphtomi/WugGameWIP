extends Control

const Wire = preload("res://app/game_screen/circuit/wire.tscn")
const Junction = preload("res://app/game_screen/circuit/junction.tscn")

var shader_material : ShaderMaterial = ShaderMaterial.new()
var alphabetter = "etaonshrdlcumwfgypbvkjxqz".split("", true, 0)
var junctions : Array
var wires : Array
const ELECTRIC_CONSTANT : float = 3000000
const SPRING_CONSTANT : float = .1
const SPRING_LENGTH : float = 600
const NUM_START_NODES = 3
const NUM_END_NODES = 3
var score : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func generate():
	generate_junctions()
	generate_wires()
	generate_animations()

func generate_junctions():
	var num_junctions : int = randi() % 3 + 7 + max(NUM_END_NODES, NUM_START_NODES)
	for i in num_junctions:
		var letter = alphabetter[randi() % alphabetter.size()]
		alphabetter.remove_at(alphabetter.find(letter))
		var vertex = Junction.instantiate()
		vertex.change_text(letter)
		if i < NUM_START_NODES:
			vertex.make_start_node()
			vertex.position = Vector2(size.x*0.1, size.y*i*0.35+(size.y*0.15))
		elif i > (num_junctions - 1 - NUM_END_NODES):
			vertex.make_end_node()
			vertex.position = Vector2(size.x*0.9, size.y*(num_junctions-i-1)*0.35+(size.y*0.15))
		else:
			vertex.position = Vector2(size.x*nice_rand(i,num_junctions), size.y*nice_rand(i,num_junctions))
		add_child(vertex)
		junctions.append(vertex)
		vertex.get_node("Letter").set_material(shader_material)

func get_central_junction_index():
	var num_central_wires = junctions.size() - NUM_START_NODES - NUM_END_NODES
	return NUM_START_NODES + randi() % num_central_wires

func new_wire(from_index: int, to_index: int):
	if to_index < from_index:
		var temp = to_index
		to_index = from_index
		from_index = temp
	var wire = Wire.instantiate()
	var from_node = junctions[from_index]
	var to_node = junctions[to_index]
	to_node.add_incoming(wire)
	from_node.add_outgoing(wire)
	add_child(wire)
	wire.set_nodes(from_node,to_node)
	wire.pop_in(0)
	wires.append(wire)

func create_terminal_wires():
	var max_junction_index = junctions.size() - 1
	for i in NUM_START_NODES:
		new_wire(i, i + NUM_START_NODES)
	for i in NUM_END_NODES:
		new_wire(max_junction_index - NUM_END_NODES - i, max_junction_index - i)

func generate_wires():
	create_terminal_wires()
	var wire_graph = []
	for i in junctions.size() - 1:
		var new_column = []
		for j in junctions.size() - 1:
			new_column.append(false)
		wire_graph.append(new_column)
	var num_central_junctions = junctions.size() - (NUM_START_NODES + NUM_END_NODES)
	var num_wires = int(num_central_junctions * randf_range(1.0, 1.5)) + 1
	while num_wires > 0:
		var x = get_central_junction_index()
		var y = get_central_junction_index()
		if x == y: continue
		if wire_graph[x][y] or wire_graph[y][x]: continue
		new_wire(x, y)
		wire_graph[x][y] = true
		wire_graph[y][x] = true
		num_wires -= 1
	
	#create_terminal_wires()
	#for i in num_central_junctions - 1:
		#var current_junction = i + NUM_START_NODES
		#var next_junction = NUM_START_NODES
		#for j in num_central_junctions:
			#if i == j: continue
			#var test_junction = junctions[j + NUM_START_NODES]
			#if test_junction.has_incoming() and test_junction.has_outgoing(): continue
			#next_junction += j
			#break
		#new_wire(current_junction, next_junction)
	
	#var num_wires : int = randi() % 7 + 12
	#for i in num_wires:
		#var fromIndex = randi() % junctions.size()
		#var toIndex = randi() % junctions.size()
		#while (fromIndex == toIndex):
			#toIndex = randi() % junctions.size()
		#if (fromIndex > toIndex):
			#var blah = toIndex
			#toIndex = fromIndex
			#fromIndex = blah
		#var from = junctions[fromIndex]
		#var to = junctions[toIndex]
		#if (!wires.is_empty()):
			#var continue_bool = false
			#for e in wires:
				#if (e.get_start()==from&&e.get_end()==to):
					#continue_bool=true
			#if (continue_bool):
				#continue
		#var edge = Wire.instantiate()
		#to.add_incoming(edge)
		#from.add_outgoing(edge)
		#add_child(edge)
		#edge.set_nodes(from,to)
		#edge.pop_in(0)
		#wires.append(edge)
		#edge.get_node("Stroke").set_material(shader_material)

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
		v.position = v.position + v.get_velocity()*delta*randf_range(0.99, 1.01)
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
		if (letters[i].contains(letters[i-1])):
			return false
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

func _on_item_rect_changed():
	var num_junctions = junctions.size()
	for i in range(num_junctions):
		if i < 3:
			junctions[i].position = Vector2(size.x*0.1, size.y*i*0.35+(size.y*0.15))
		elif i > (num_junctions - 4):
			junctions[i].position = Vector2(size.x*0.9, size.y*(num_junctions-i-1)*0.35+(size.y*0.15))
	pass # Replace with function body.

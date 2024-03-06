extends Node2D

var shader_material : ShaderMaterial
var alphabetter = "etaonshrdlcumwfgypbvkjxqz".split("", true, 0)
var vertices : Array
var edges : Array
var size : Vector2
const ELECTRIC_CONSTANT : float = 3000000
const SPRING_CONSTANT : float = .1
const SPRING_LENGTH : float = 600

# Called when the node enters the scene tree for the first time.
func _ready():
	size = get_viewport().content_scale_size - Vector2i(300,0)
	var num_vertices : int = randi() % 3 + 10
	var num_edges : int = randi() % 7 + 12
	var vertex_scene = preload("res://testNode.tscn")
	var edge_scene = preload("res://wire.tscn")
	shader_material = ShaderMaterial.new()
	shader_material.shader = load("res://shader.gdshader")
	
	#generates num_vertices
	for i in num_vertices:
		var letter = alphabetter[randi() % alphabetter.size()]
		alphabetter.remove_at(alphabetter.find(letter))
		var vertex = vertex_scene.instantiate()
		vertex.change_text(letter)
		vertex.position = Vector2(size.x*nice_rand(i,num_vertices), size.y*nice_rand(i,num_vertices))
		add_child(vertex)
		vertices.append(vertex)
		vertex.get_node("Letter").set_material(shader_material)
	
	#generates num_edges
	for i in num_edges:
		var fromIndex = randi() % vertices.size()
		var toIndex = randi() % vertices.size()
		while (fromIndex == toIndex):
			toIndex = randi() % vertices.size()
		if (fromIndex > toIndex):
			var blah = toIndex
			toIndex = fromIndex
			fromIndex = blah
		var from = vertices[fromIndex]
		var to = vertices[toIndex]
		if (!edges.is_empty()):
			var continue_bool = false
			for e in edges:
				if (e.get_start()==from&&e.get_end()==to):
					continue_bool=true
			if (continue_bool):
				continue
		var edge = edge_scene.instantiate()
		to.add_incoming(edge)
		from.add_outgoing(edge)
		add_child(edge)
		edge.set_nodes(from,to)
		edge.pop_in(0)
		edges.append(edge)
		edge.get_node("Stroke").set_material(shader_material)
	
	#creates the animation for each vertex (and after the animations for each
	#vertex completes, it animates out its edges)
	for i in num_vertices:
		var vertex = vertices[num_vertices-1-i]
		pop_in_vertex(vertex, i)

#does electric force on each pair of vertices, then spring force
#on each wire, then calculates the vertices movements
func _process(delta):
	for i in vertices.size():
		for j in range(i,vertices.size()):
			coolombs(vertices[i],vertices[j], delta)
	for e in edges:
		hookes(e,delta)
	for v in vertices:
		border_force(v,delta)
		v.position = v.position + v.get_velocity()*delta
		v.position = Vector2(clamp(v.position.x,0,size.x),clamp(v.position.y,0,size.y))
	
#electric force
func coolombs(v1 : TestNode, v2 : TestNode, delta : float):
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
func border_force(v : TestNode, delta):
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
func _on_text_field_text_submitted(_new_text):
	var letterArray = $Control/TextField.text.split("", false, 0)
	var update_wires : Dictionary
	for i in (letterArray.size() - 1):
		var wire = get_wire(letterArray[i], letterArray[i+1])
		if wire == null:
			$Control/TextField.clear()
			return
		update_wires[wire]=null
	for w in update_wires.keys():
		w.increment_thickness()
	$Control/Label.text = $Control/Label.text + $Control/TextField.text + "\n "
	$Control/TextField.clear()	
		
# Gets a wire based on its start and end letter (does not depend on direction, at the moment)
func get_wire(startNodeLetter: String, endNodeLetter: String):
	for wire in edges:
		if wire.check_connecting_letters(startNodeLetter, endNodeLetter):
			return wire
	return null
	
func nice_rand(i: float, n : float):
	return .15 + .4*(i/n) +.3*randf()

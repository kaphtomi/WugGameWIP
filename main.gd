extends Node2D

#var rng = RandomNumberGenerator.new()
var shader_material : ShaderMaterial
const alpha = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
const alphabest = "eeeeeeeeeeeetttttttttaaaaaaaaooooooiiiiiiinnnnnnsssssshhhhhhrrrrrrddddllllcccuuuummmwwffggyyppbbvkjxqz"
var vertices : Array
var edges : Array
var size : Vector2
const ELECTRIC_CONSTANT : float = 200000
const SPRING_CONSTANT : float = .01
const SPRING_LENGTH : float = 400

# Called when the node enters the scene tree for the first time.
func _ready():
	size = get_viewport().content_scale_size
	var numVertices : int = randi() % 3 + 10
	var numEdges : int = randi() % 5 + 9
	var vertexScene = preload("res://testNode.tscn")
	var edgeScene = preload("res://wire.tscn")
	shader_material = ShaderMaterial.new()
	shader_material.shader = load("res://shader.gdshader")
	for i in numVertices:
		var letter = alphabest[randi() % alphabest.length()]
		var vertex = vertexScene.instantiate()
		vertex.change_text(letter)
		vertex.position = Vector2(size.x*(.1+.9*randf()), size.y*(.1+.9*randf()))
		add_child(vertex)
		vertices.append(vertex)
		vertex.get_node("Letter").set_material(shader_material)
		vertex.set_size(size)
	
	for i in numEdges:
		var fromIndex = randi() % vertices.size()
		var toIndex = randi() % vertices.size()
		while (fromIndex == toIndex):
			toIndex = randi() % vertices.size()
		var from = vertices[fromIndex]
		var to = vertices[toIndex]
		var edge = edgeScene.instantiate()
		to.add_incoming(edge)
		from.add_outgoing(edge)
		add_child(edge)
		edge.set_nodes(from,to)
		edge.pop_in(0)
		edges.append(edge)
		edge.get_node("Stroke").set_material(shader_material)
	
	for i in numVertices:
		var vertex = vertices[i]
		pop_in_vertex(vertex, i)
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for i in vertices.size():
		for j in range(i,vertices.size()):
			coolombs(vertices[i],vertices[j], delta)
	#var size = get_viewport().content_scale_size
	for e in edges:
		hookes(e,delta)
	for v in vertices:
		border_force(v,delta)
		v.position = v.position + v.get_velocity()*delta*10
		v.position = Vector2(clamp(v.position.x,0,size.x),clamp(v.position.y,0,size.y))
	pass
			
			
func coolombs(v1 : TestNode, v2 : TestNode, delta : float):
	var p1 : Vector2 = v1.position
	var p2 : Vector2 = v2.position
	var r : Vector2 = p2 - p1
	var f : Vector2 = ELECTRIC_CONSTANT / (r.length_squared()+1) * r.normalized()
	v1.force(-f*delta)
	v2.force(f*delta)

func hookes(e, delta : float):
	var v1 = e.get_start()
	var v2 = e.get_end()
	var p1 : Vector2 = v1.position
	var p2 : Vector2 = v2.position
	var d : Vector2 = p2 - p1
	var s = d.length()-SPRING_LENGTH
	var f : Vector2 = -SPRING_CONSTANT * s * d.normalized()
	v1.force(-f*delta)
	v2.force(f*delta)

func border_force(v : TestNode, delta):
	var p : Vector2 = v.position
	var k = ELECTRIC_CONSTANT
	v.force(Vector2(k*delta*(1/(p.x ** 2 + 1) - 1/((p.x-size.x) ** 2 + 1)),k*delta*(1/(p.y ** 2 + 1) - 1/((p.y-size.y) ** 2 + 1))))
	


func pop_in_vertex(v, i:int):
	v.scale = Vector2.ZERO
	var tween = create_tween()
	var wait = .3*i
	var dur = .2
	var callable = Callable(self, "pop_in_edges")
	callable.bind(v,wait+dur)
	tween.tween_interval(wait)
	tween.tween_property(v, "scale", (1+randf()*.3)*Vector2.ONE, dur)
	tween.tween_property(v, "scale", Vector2.ONE, randf()*.1)
	tween.tween_callback(v.pop_in_edges)
	tween.play()

extends Control

const Wire = preload("res://app/game_screen/circuit/wire.tscn")
const Junction = preload("res://app/game_screen/circuit/junction.tscn")

# Sent when there are not enough wires left to play the game
signal circuit_broken
var circuit_is_broken = false

var alphabetter = "ETAONSHRDLCUMWFGYPBVKJXQZI".split("", true, 0)
var junction_map = {}
var junctions : Array
var wires : Array
const ELECTRIC_CONSTANT : float = 30000000
const SPRING_CONSTANT : float = .1
const SPRING_LENGTH : float = 800
const SPRING_SNAP : float = 1000
var score : int = 0
var time: float = 0
var counter: int = 0
var mouse_pos = Vector2.ZERO
var grabbed = null
var in_radius
var out_radius
var in_radius_to
var out_radius_to
var kill = false
var cur_word = {}
var handling_letter = false
var words: Array = []
# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass

# GENERATION
func generate():
	in_radius = 4000.0 * get_viewport().size.x/1600.0
	out_radius = 4000.0 * get_viewport().size.x/1600.0
	in_radius_to = in_radius
	out_radius_to = out_radius
	generate_junctions(randi() % 3 + 9)

func generate_junctions(num_junctions : int):
	for i in num_junctions:
		var junc = generate_junction(randi() % 2+1)
		if junc!= null:
			pop_in_junction(junc,i)
	
func generate_junction(num_wires : int):
	if (alphabetter.is_empty()):
		return null
	var letter = alphabetter[randi() % alphabetter.size()]
	alphabetter.remove_at(alphabetter.find(letter))
	var junc = Junction.instantiate()
	junc.set_letter(letter)
	junc.position = Vector2(size.x*(.15+.7*randf()), size.y*(.15+.7*randf()))
	add_child(junc)
	generate_wires(junc, num_wires)
	junctions.append(junc)
	junction_map[letter]=junc
	return junc
	
func generate_wires(from, num_wires : int):
	var juncs = junctions.duplicate()
	for i in num_wires:
		if juncs.is_empty():
			return
		var to = juncs.pop_at(randi() % juncs.size())
		generate_wire(from, to)

func generate_wire(from, to):
	var wire = Wire.instantiate()
	wire.set_nodes(from, to)
	wire.pop_in(0)
	add_child(wire)
	wires.append(wire)
	return wire

#copy the set of junctions, to juncs then pop one at random, try to find a connection
#that doesn't already have an edge, if there are no connections that don't have
#edges then its removed from juncs so we loop, popping a different junc at 
# random and loop and then finally if juncs ends up empty at the beginning 
# then we know every wire already exists
func generate_random_wire():
	var juncs = junctions.duplicate()
	var from
	var to
	while true:
		if juncs.is_empty():
			return
		from = juncs.pop_at(randi() % juncs.size())
		var juncs2 = juncs.duplicate()
		var connections = from.get_connections()
		for c in connections:
			juncs2.erase(c)
		if !juncs2.is_empty():
			to = juncs2.pop_at(randi() % juncs2.size())
			break
	var w = generate_wire(from,to)
	if from.popped_in:
		from.pop_in_wire(w)


# INPUT

var selected_junction
var word = ""
var affected_junctions = []
var connecting_wires = []
var potential_wires = []

signal word_submitted

# Checks if currently selected word is not in word list
func validate_word():
	if word in words:
		for w in connecting_wires: w.flash_red()
		for j in affected_junctions: j.flash_red(false)
	else:
		if word.length() > 0: words.append(word)
		score_word(word)
		for j in affected_junctions: j.pulse_and_reset()
	selected_junction = null
	for w in connecting_wires: w.clear_highlight()
	for w in potential_wires: w.clear_highlight()
	word = ""
	connecting_wires = []
	potential_wires = []
	affected_junctions = []

# Checks to see if junction is connected to previously selected junction
func validate_junction(junction, input):
	var connection
	for w in potential_wires:
		if w == null: continue
		if w.check_connecting_letters(junction.get_letter(), selected_junction.get_letter()):
			connection = w
			var invert_highlight_direction = w.get_end().get_letter() == selected_junction.get_letter()
			w.highlight_green(invert_highlight_direction)
			break
		else: continue
	if connection == null: 
		if not word.ends_with(input):
			for w in connecting_wires: w.flash_red()
			for j in affected_junctions: j.flash_red()
		return false
	for w in potential_wires: w.clear_highlight(2)
	potential_wires = []
	connecting_wires.append(connection)
	selected_junction.set_selected()
	return true

# Checks difficulty and, if applicable, highlights potential wires blue
func highlight_wires():
	for w in selected_junction.outgoing_edges:
		if w in connecting_wires: continue
		if GlobalVariables.cur_dif == GlobalVariables.WUG_DIFF.EASY:
			w.highlight_blue()
		else: w.block_decay = true
		potential_wires.append(w)
	for w in selected_junction.incoming_edges:
		if w in connecting_wires: continue
		if GlobalVariables.cur_dif == GlobalVariables.WUG_DIFF.EASY:
			w.highlight_blue(true)
		else: w.block_decay = true
		potential_wires.append(w)

func _input(event):
	var input = event.as_text()
	if input == "Enter": validate_word()
	if not input in "QWERTYUIOPASDFGHJKLZXCVBNM/": return
	var junction = junction_map.get(input)
	if junction == null: return
	if selected_junction and not validate_junction(junction, input): return
	
	junction.set_potential()
	selected_junction = junction
	affected_junctions.append(junction)
	
	highlight_wires()

	word += selected_junction.get_letter()


# PROCESS
func _process(delta):
	match GlobalVariables.cur_zzz:
		GlobalVariables.WUG_ZZZ.AWAKE:
			in_radius_to = 4000.0 * get_viewport().size.x/1600.0
			out_radius_to = 4000.0 * get_viewport().size.x/1600.0
		GlobalVariables.WUG_ZZZ.SLEEP:
			in_radius_to = (190.0-score/50.0) * get_viewport().size.x/1600.0
			out_radius_to = (200.0-score/50.0) * get_viewport().size.x/1600.0
	time += delta
	if Input.is_action_just_pressed("click"):
		for junc in junctions:
			if junc.position.distance_to(get_viewport().get_mouse_position())<80:
				grabbed = junc
				break
	if Input.is_action_just_released("click"):
		grabbed = null
	mouse_pos = lerp(mouse_pos,get_viewport().get_mouse_position()/Vector2(get_viewport().size),.1)
	in_radius = lerp(in_radius,in_radius_to,delta)
	out_radius = lerp(out_radius,out_radius_to,delta)
	RenderingServer.global_shader_parameter_set("mouse_pos", mouse_pos)
	RenderingServer.global_shader_parameter_set("in_radius", in_radius)
	RenderingServer.global_shader_parameter_set("out_radius", out_radius)
	for wire in wires:
		if kill:
			wire.decay(delta*500,score+10)
		if wires.size() == 1:
			wire.decay(delta*2,score)
		if (wire.decay(delta,score)):
			snap(wire)
			break
	physics(delta)
	
	var pop_outs = {}
	for junc in junctions:
		if junc.get_connections().is_empty():
			pop_outs[junc]=true
	
	for junc in pop_outs.keys():
		if !circuit_is_broken:
			pop_out_junction(junc, delta)
	if grabbed != null && !circuit_is_broken:
		grabbed.position = lerp(grabbed.position,get_viewport().get_mouse_position(),.1)

#SCORING
func is_word_in_circuit(word : String):
	var letters = word.split("", false, 0)
	var update_wires : Dictionary = {}
	for i in (letters.size()-1):
		var wire = get_wire(letters[i], letters[i+1])
		if wire == null:
			return false
	return true

func score_word(word : String):
	var letters = word.split("", false, 0)
	var update_wires : Dictionary = {}
	for i in (letters.size()-1):
		var wire = get_wire(letters[i], letters[i+1])
		update_wires[wire]=true
	var s = 0
	for w in update_wires:
		w.increment_thickness()
		if w.score_wire():
			s+=1
		s+=2
	score+=s
	if junctions.size() > 7:
		s -= junctions.size()-7
	if junctions.size() > 11:
		s -= junctions.size()-11
	if s>10:
		s=10
	add_to_graph(s)
	word_submitted.emit(word)

func add_to_graph(amt):
	match amt:
		4:
			generate_random_wire()
		5:
			generate_random_wire()
			generate_random_wire()
		6:
			var junc = generate_junction(1)
			if junc != null:
				pop_in_junction(junc,0)
		7:
			var junc = generate_junction(2)
			if junc != null:
				pop_in_junction(junc,0)
		8:
			var junc = generate_junction(2)
			if junc != null:
				pop_in_junction(junc,0)
			generate_random_wire()
		9:
			var junc = generate_junction(3)
			if junc != null:
				pop_in_junction(junc,0)
			generate_random_wire()
		10:
			var junc = generate_junction(3)
			if junc != null:
				pop_in_junction(junc,0)
			generate_random_wire()
			generate_random_wire()

# PHYSICS
func physics(delta):
	for i in junctions.size():
		for j in range(i,junctions.size()):
			coolombs(junctions[i],junctions[j], delta)
	for wire in wires:
		hookes(wire,delta)
	for junc in junctions:
		border_force(junc,delta)
		junc.position = junc.position + junc.get_velocity()*delta
		junc.position = Vector2(clamp(junc.position.x,.1*size.x,.9*size.x),clamp(junc.position.y,.1*size.y,.9*size.y))
	
#electric force
func coolombs(v1, v2, delta : float):
	var p1 : Vector2 = v1.position
	var p2 : Vector2 = v2.position
	var r : Vector2 = p2 - p1
	var f : Vector2 = ELECTRIC_CONSTANT / (r.length_squared()+1) * r.normalized()
	v1.force(-f*delta)
	v2.force(f*delta)

#border_force
func border_force(v, delta):
	var p : Vector2 = v.position
	var k = ELECTRIC_CONSTANT
	var fx = k*delta*(1/(p.x ** 2 + 1) - 1/((p.x-size.x) ** 2 + 1))
	var fy = k*delta*(1/(p.y ** 2 + 1) - 1/((p.y-size.y) ** 2 + 1))
	v.force(Vector2(fx*(1+.25*sin(p.y/200+time*.5)),fy*(1+.15*cos(p.x/370+time*.7))))

#spring force
func hookes(wire, delta : float):
	var from = wire.get_start()
	var to = wire.get_end()
	var start : Vector2 = from.position
	var end : Vector2 = to.position
	var d : Vector2 = end - start
	var s = max(d.length()-SPRING_LENGTH / sqrt(wire.thickness),0) 
	var f : Vector2 = -(SPRING_CONSTANT * wire.thickness * wire.thickness)* s * d.normalized() * wire.done* wire.done
	from.force(-f*delta)
	to.force(f*delta)

func snap(wire):
	wire.snap()
	var from = wire.get_start()
	var to = wire.get_end()
	var s = to.position-from.position
	var snap_text = Label.new()
	snap_text.text = ["snap","snap","snap","snap","snap!","ssnap","snap!","snip"].pick_random()
	var angle = s.angle()
	if angle < -PI/2:
		angle+=PI
	if angle > PI/2:
		angle-=PI
	if angle < -PI/4:
		angle += PI/2
	if angle > PI/4:
		angle -=PI/2
	snap_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	snap_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	snap_text.pivot_offset = snap_text.size/2
	snap_text.rotation = angle
	snap_text.position = from.position+(s*.5)
	
	snap_text.set_theme(load("res://assets/text_theme.tres"))
	add_child(snap_text)
	var tween = create_tween()
	snap_text.modulate = wire.get_color()
	tween.tween_interval(.2)
	tween.tween_property(snap_text, "modulate",Color(wire.get_color(),0),.1)
	tween.tween_callback(snap_text.queue_free)
	tween.play()
	from.force(-s.normalized()*SPRING_SNAP)
	to.force(s.normalized()*SPRING_SNAP)
	wires.remove_at(wires.find(wire))
	wire.queue_free()
	
	if wires.is_empty(): # Ends the game when there is one wire left
		circuit_broken.emit()

func pop_in_junction(v, i:int):
	v.scale = Vector2.ZERO
	var tween = create_tween()
	var wait = .15*i
	var dur = .25
	tween.tween_interval(wait)
	tween.tween_property(v, "scale", (1+randf()*.3)*Vector2.ONE, dur)
	tween.tween_property(v, "scale", Vector2.ONE, randf()*.1)
	tween.tween_callback(v.pop_in_wires)
	tween.play()

func pop_out_junction(junc, delta):
	junctions.erase(junc)
	junction_map.erase(junc)
	alphabetter.append(junc.get_letter())
	junc.scale = Vector2.ONE
	var tweensize = create_tween()
	var tweenopac = create_tween()
	var tweenmove = create_tween()
	var dur = .4
	tweenmove.tween_method(junc.move,junc.velocity*delta*.7,junc.velocity.rotated(2*randf()-1)*.5*delta,dur)
	tweensize.tween_property(junc, "scale", Vector2.ONE*1.5, dur)
	tweenopac.tween_property(junc, "modulate", Color(1,1,1,0), dur)
	tweensize.tween_callback(junc.queue_free)
	tweensize.play()
	tweenopac.play()
	tweenmove.play()

# Gets a wire based on its start and end letter (does not depend on direction, at the moment)
func get_wire(startNodeLetter: String, endNodeLetter: String):
	for wire in wires:
		if wire.check_connecting_letters(startNodeLetter, endNodeLetter):
			return wire
	return null
	
func kill_circuit():
	kill=true

func _on_item_rect_changed():
	var num_junctions = junctions.size()
	for i in range(num_junctions):
		if i < 3:
			junctions[i].position = Vector2(size.x*0.1, size.y*i*0.35+(size.y*0.15))
		elif i > (num_junctions - 4):
			junctions[i].position = Vector2(size.x*0.9, size.y*(num_junctions-i-1)*0.35+(size.y*0.15))

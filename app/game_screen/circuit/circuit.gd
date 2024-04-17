extends Control

const Wire = preload("res://app/game_screen/circuit/wire.tscn")
const Junction = preload("res://app/game_screen/circuit/junction.tscn")

# Sent when there are not enough wires left to play the game
signal circuit_broken
var circuit_is_broken = false

var alphabetter = "ETAONSHRDLCUMWFGYPBVKJXQZI".to_lower().split("", true, 0)
var junction_map = {}
var junctions : Array
var wires : Array
const ELECTRIC_CONSTANT : float = 30000000
const SPRING_CONSTANT : float = .1
const SPRING_LENGTH : float = 800
const SPRING_SNAP : float = 1000
var score : int = 0
var sketch_time: float = 0
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
var text = ""
# Called when the node enters the scene tree for the first time.
func _ready():
	$LineEdit.grab_focus()
	pass

#region GENERATION
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
#endregion

#region INPUT

var selected_junction #the last junction in the word
var affected_junctions = [] #all junctions in word (including selected)
var potential_junctions = {} #all junctions connecting to selected & haven't used the wire yet
var potential_wires = {}
var connecting_wires = [] #path of wires in the word
var word_invalid = false #if current word is valid or not

signal word_submitted

# Checks if currently selected word (text) is not in word list
func validate_word():
	#not a word
	if word_invalid:
		clear_word_selection()
		flash_all_red()
		return
	#repeat
	elif text in words:
		for w in connecting_wires: w.flash_red()
		for j in affected_junctions: j.flash_red(false)
	else:
		if text.length() > 1: words.append(text)
		score_word(text)
		for j in affected_junctions: j.pulse_and_reset()
	clear_word_selection()

func clear_word_selection():
	selected_junction = null
	for w in wires:
		w.clear_highlight()
	for j in junctions: 
		j.clear_highlight()
	text = ""
	connecting_wires = []
	affected_junctions = []
	word_invalid=false

func process_invalid_input(input):
	word_invalid=true
	flash_all_red()
	return

func reset_potential_wires():
	for w in potential_wires:
		w.clear_highlight()
	potential_wires = {}
	if GlobalVariables.cur_dif == GlobalVariables.WUG_DIFF.EASY:
		for junc in potential_junctions:
			var potential_wire = get_wire(junc.get_letter(), selected_junction.get_letter())
			potential_wire.potential_highlight(junc)
			potential_wires[potential_wire]=true
		
func flash_all_red():
	for w in wires: w.flash_red()
	for j in junctions: j.flash_red()

func _on_line_edit_text_changed(new_text):
	if text==""&&new_text=="":
		return
	#longer case
	if text.length() == new_text.length()-1:
		#added to end case
		if new_text.begins_with(text):
			char_added(new_text[-1])
		#just in case
		else:
			re_do(new_text)
	#shorter case
	if text.length() == new_text.length()+1:
		#subtracted from end case
		if text.begins_with(new_text):
			char_removed()
		else:
			re_do(new_text)
	#weird case
	if abs(text.length()-new_text.length())!=1:
		re_do(new_text)
	text = new_text

#adds the wire connecting selected_junction and junc to the connecting wires
func connect_to(junc):
	var connection = get_wire(selected_junction.get_letter(),junc.get_letter())
	connecting_wires.append(connection)
	potential_wires.erase(connection) #when we reset the potential wires, we clear highlights, but we don't want that to apply to this connection
	connection.valid_highlight(junc)

func _on_line_edit_text_submitted(_new_text):
	validate_word()

func re_do(input):
	clear_word_selection()
	for i in input.length():
		char_added(input[i])

func char_added(character):
	if word_invalid:
		return
	var junction = junction_map.get(character)
	if junction == null:
		process_invalid_input(character)
		return
	if text!="":
		if potential_junctions.get(junction) == null:
			process_invalid_input(character)
			return
		connect_to(junction)
	select_junction(junction)

func select_junction(junc):
	junc.set_potential()
	selected_junction = junc
	affected_junctions.append(junc)
	potential_junctions = junc.get_connections()
	for w in connecting_wires:
		var other = w.other(junc)
		if other != null:
			potential_junctions.erase(other)
	reset_potential_wires()
	

func char_removed():
	if !word_invalid:
		var backspaced_junction = affected_junctions.pop_back()
		backspaced_junction.clear_highlight()
		if affected_junctions != null:
			var backspaced_wire = connecting_wires.pop_back()
			backspaced_wire.clear_highlight()
			select_junction(junction_map.get(text[-1]))
		return
	re_do(text.left(-1))
	
	

#endregion

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
	sketch_time += delta
	var sketch = false
	if sketch_time> .167:
		sketch_time=0
		sketch=true
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
		if sketch: 
			wire.sketch()
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
		if sketch: 
			junc.sketch()
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
	if wires.size() > 15:
		s -= wires.size()-15
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

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
const ELECTRIC_CONSTANT : float = 40000000
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
var handling_letter = false
var words: Dictionary = {}
const max_scale = 1.1
var cursor_tween
var submitted_path = []

# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalVariables.switching_to_zzz_mode.connect(pulse_cursor)
	$CurrentWordLabel.text = ""  # Empties the current word label with a new circuit
	reset_all_input_defaults()

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
var selected_junction # last letter typed, null if word empty
var word # current word, may have wrong letters at any point
var word_valid # true if word is currently valid, false otherwise
var affected_junctions # list of valid junctions in word, in order. contains selected junction. used for graphics
var connecting_wires # wires that connect affected junctions. used for graphics, and to determine potential wires
var potential_wires # wires that connect to selected junction that aren't in connecting wires
var potential_junctions # junctions that connect to selected junction. false if there's a connection, but it's already in connecting wires
signal word_submitted

#DO NOT CALL THIS DIRECTLY, OTHER METHODS ARE USED TO MAKE SURE STATE IS MAINTAINED
func reset_all_input_defaults():
	selected_junction = null
	word = ""
	word_valid = true
	affected_junctions = []
	$CurrentWordLabel.text = word
	connecting_wires = []
	potential_wires = {}
	potential_junctions = {}

#checks if word is in circuit
func is_word_in_circuit():
	var letters = word.split("", false, 0)
	if letters.size()==1:
		if junction_map.get(word)==null:
			return false
		return true
	for i in (letters.size()-1):
		if i+2<letters.size():
			if letters[i]==letters[i+2]:
				return false
		var wire = get_wire(letters[i], letters[i+1])
		if wire == null:
			return false
	return true

#called on enter. if the word is invalid, clear
#if the word is valid and has already been entered, sad path + clear
#if the word is valid hasn't been entered, and has multiple letters, score + happy path
#then pulse reset affected junctions and clear word 
func submit_word():
	if !word_valid:
		clear_word_selection()
		return
	if words.get(word):
		sad_path()
	else:
		if word.length() > 1: 
			words[word]=true
			score_word(word)
			happy_path()
	
	for j in affected_junctions: j.pulse_and_reset()
	clear_word_selection()

#helper for happy and sad paths, which starts the new path and clears the old one if applicable
func set_submitted_path(path):
	path[0].pop_out()
	if !submitted_path.is_empty():
		for h in submitted_path:
			h.queue_free()
	submitted_path=path

#slowly retracts the highlight path from a duplicate word and doesn't change its color
func sad_path():
	var path = []
	for w in connecting_wires:
		var h = w.path_to_higherlights()
		path.append(h)
	set_submitted_path(path)

#quickly retracts the highlight path from a new word, changes its color, and it makes the graph wiggle
func happy_path():
	var path = []
	var i = 0
	for w in connecting_wires:
		i+=1
		var h = w.path_to_higherlights()
		h.happy_out()
		h.happiness=i
		path.append(h)
	set_submitted_path(path)
	
#clears all the highlights (except for highlights in submitted_path) and resets everything
func clear_word_selection():
	for w in wires:
		if w == null: continue
		w.clear_highlights()
	for j in junctions: 
		j.clear_highlight()
	unset_all_red()
	reset_all_input_defaults()

#called if a wire snaps in the current word
#TODO sound effect
func void_current_word():
	clear_word_selection()

# Checks to see if junction is connected to previously selected junction
func validate_junction(junction):
	return potential_junctions.get(junction)

#adds a junction to the end of the word. only call this if
#a) the word is currently valid
#b) the junction has a wire connecting it to the last junction (selected junction) 
#c) that wire isn't already in connecting wires
#TODO typing sfx (maybe it should be in a more general place, 
#still making the typing noise even if it doesn't add to word i'm not sure)
func add_to_word(junction):
	var connection = get_wire(selected_junction.get_letter(), junction.get_letter())
	var invert_highlight_direction = connection.get_end().get_letter() == selected_junction.get_letter()
	connection.highlight_path(invert_highlight_direction)
	clear_potential_highlights()
	potential_wires = {}
	connecting_wires.append(connection)
	deselect_junction(selected_junction)
	affected_junctions[-1].affected = true

#clears all the potential highlights (with a fun animation)
func clear_potential_highlights():
	for w in potential_wires:
		if w == null: continue
		w.clear_potential_highlight()

# should it be called when junction == null in char_inputted? i don't know what that case
# was for, perhaps it cannot happen anymore
func process_invalid_input():
	if word_valid:
		set_all_red()
		word_valid = false
	pulse_all()
	return

# highlights potential wires blue
func highlight_wires():
	for w in potential_wires:
		w.highlight_potential(w.get_end().get_letter() == selected_junction.get_letter())

#sets everything red
func set_all_red():
	for w in wires: w.set_red()
	for j in junctions: j.set_red()
	$WrongSFX.play()

#TODO add a good sound effect
func unset_all_red():
	for w in wires: w.unset_red()
	for j in junctions: j.unset_red()
	

func pulse_all():
	for j in junctions: j.pulse()

#a pain for sure but it works except in the rare bug mentioned below
func do_backspace():
	if word.length()<2:
		clear_potential_highlights()
		deselect_junction(selected_junction)
		unset_all_red()
		reset_all_input_defaults()
		return
	word = word.left(-1)
	$CurrentWordLabel.text=word
	if is_word_in_circuit():
		if !word_valid:
			word_valid = true
			unset_all_red()
			return
		for w in potential_wires: w.clear_potential_highlight()
		var end_junc = affected_junctions.pop_back()
		deselect_junction(end_junc)
		
		#VERY STRANGE HARD TO REPRODUCE BUG, THIS PROTECTS AGAINST IT BUT ITS NOT
		#GREAT (spam adjacent letters and backspace a lot to maybe reproduce)
		#(somehow the connecting wires is null when it shouldn't be based on)
		#(the invariants that seem to mostly hold)
		var cwb = connecting_wires.pop_back() 
		if cwb!=null: cwb.clear_path_highlight()
		else: 
			clear_word_selection()
			return
		
		select_junction(affected_junctions.pop_back())
		highlight_wires()
	
	
#deselects the junction. make sure you call it on the selected junction. 
#TODO maybe i should change this to not take a parameter
func deselect_junction(junction):
	selected_junction = null
	if junction!=null:
		junction.deselect()

#selects the junction, AND APPENDS IT TO AFFECTED JUNCTIONS. 
#the second bit might cause more confusion than it's worth
func select_junction(junction):
	junction.set_selected()
	selected_junction = junction
	affected_junctions.append(junction)
	reset_potentials()
	
#resets the potentials for the selected junction, without redrawing
func reset_potentials():
	potential_wires = {}
	potential_junctions = selected_junction.get_connections()
	for junc in potential_junctions:
		var p_wire = get_wire(junc.get_letter(), selected_junction.get_letter())
		for wire in connecting_wires:
			if p_wire == wire:
				potential_junctions[junc]=false
		if potential_junctions[junc]:
			potential_wires[p_wire]=true
	



func _input(event):
	if event is InputEventMouseMotion and cursor_tween != null:
		cursor_tween.kill()
		CustomCursor.update_cursor(GlobalVariables.cursor_base_scale)  # Auto-resets the cursor when the mouse is moved
	if event.is_echo()||event.is_released():
		return
	var input = event.as_text()
	if input == "Slash":
		pass
	if input == "Enter": 
		submit_word()
		return
	elif input == "Backspace":
		do_backspace()
		return
	elif input in "QWERTYUIOPASDFGHJKLZXCVBNM":
		char_inputted(input)
		return

#again, not sure about the junction==null case, should it process invalid input? 
#my brain says the game has gone horribly wrong if we reach that case. the new word
#is in the circuit, but the junction is missing from the map of junctions
func char_inputted(input):
	word += input
	$CurrentWordLabel.text = word
	if !is_word_in_circuit():
		process_invalid_input()
		return
	var junction = junction_map.get(input)
	if junction == null:
		return
	if selected_junction:
		if validate_junction(junction): 
			add_to_word(junction)
		else:
			process_invalid_input()
			return
	select_junction(junction)
	highlight_wires()
#endregion

# PROCESS
func grab_junction():
	if Input.is_action_just_pressed("click"):
		for junc in junctions:
			if junc.position.distance_to(get_viewport().get_mouse_position())<80:
				grabbed = junc
				break
	if Input.is_action_just_released("click"):
		grabbed = null

func process_flashlight(delta):
	match GlobalVariables.cur_zzz:
		GlobalVariables.WUG_ZZZ.AWAKE:
			in_radius_to = 4000.0 * get_viewport().size.x/1600.0
			out_radius_to = 4000.0 * get_viewport().size.x/1600.0
		GlobalVariables.WUG_ZZZ.SLEEP:
			in_radius_to = (190.0-score/50.0) * get_viewport().size.x/1600.0
			out_radius_to = (200.0-score/50.0) * get_viewport().size.x/1600.0
	mouse_pos = lerp(mouse_pos,get_viewport().get_mouse_position()/Vector2(get_viewport().size),.1)
	in_radius = lerp(in_radius,in_radius_to,delta)
	out_radius = lerp(out_radius,out_radius_to,delta)
	RenderingServer.global_shader_parameter_set("mouse_pos", mouse_pos)
	RenderingServer.global_shader_parameter_set("in_radius", in_radius)
	RenderingServer.global_shader_parameter_set("out_radius", out_radius)

func process_wires(sketch: bool, delta):
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
			
func process_junctions(sketch, delta):
	var pop_outs = {}
	for junc in junctions:
		if sketch: 
			junc.sketch()
		if junc.get_connections().is_empty():
			pop_outs[junc]=true
			if junc in affected_junctions:
				clear_word_selection()
	
	for junc in pop_outs.keys():
		if !circuit_is_broken:
			pop_out_junction(junc, delta)
			
			

	
func _process(delta):
	
	
	if selected_junction && selected_junction.highlight_state != 2:
		selected_junction.set_potential()
	
	time += delta
	sketch_time += delta
	var sketch = false
	if sketch_time> .167:
		sketch_time=0
		sketch=true
	
	grab_junction()
	process_flashlight(delta)
	process_wires(sketch, delta)
	physics(delta)
	if !submitted_path.is_empty():
		animate_submitted_path()
	
	process_junctions(sketch, delta)
	if grabbed != null && !circuit_is_broken:
		grabbed.position = lerp(grabbed.position,get_viewport().get_mouse_position(),.1)
#endregion

#region SCORING
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
#endregion

# PHYSICS
func physics(delta):
	for i in junctions.size():
		for j in range(i,junctions.size()):
			coolombs(junctions[i],junctions[j], delta)
		for w in wires:
			coolerombs(junctions[i],w,delta)
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

func coolerombs(v,w,delta):
	var p = v.position
	var a = w.get_start().position
	var n = w.get_end().position
	var d = (p - a) - ((p - a).dot(n))*n
	var f = 1000*ELECTRIC_CONSTANT / (d.length_squared()+1.0) * d.normalized()
	v.force(f*delta)
	pass

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
	$SnapSFX.play()
	if wire in connecting_wires: void_current_word()
	if wire in potential_wires:
		potential_wires.erase(wire)
		potential_junctions.erase(wire.get_end())
		potential_junctions.erase(wire.get_start())
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
	$PopInSFX.play()

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
	$PopOutSFX.play()

#checks if the head of the path ended it's animation, in which case we remove & free it,
#and then start the next one. if that highlight was happy, then it knocks it's end node
#a bit, depending on how long the path was.
func animate_submitted_path():
	if !submitted_path.is_empty():
		var h = submitted_path[0]
		if h!= null:
			h.pop_out()
			if h.ended:
				if h.happy:
					var happy = h.happiness
					var start = h.get_parent().get_start()
					var end = h.get_parent().get_end()
					var d = end.position-start.position
					if h.direction:
						d *= -1
						start.force(100*happy*d.normalized())
					else:
						end.force(100*happy*d.normalized())
				h.queue_free()
				submitted_path.pop_front()
		else: submitted_path.pop_front()

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


func pulse_cursor():
	cursor_tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE).set_loops()
	cursor_tween.tween_method(CustomCursor.update_cursor, GlobalVariables.cursor_base_scale, max_scale, 1)
	cursor_tween.tween_method(CustomCursor.update_cursor, max_scale, GlobalVariables.cursor_base_scale, 1)
	cursor_tween.tween_interval(0.25)
	cursor_tween.play()
	

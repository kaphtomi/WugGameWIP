extends AnimatableBody2D

var _in_node: TestNode	
var _out_node: TestNode
var done = 0.0
var connecting_letters: Array[String] = []
var thickness: int = 1
const WIDTH_SCALE: int = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	# Gives the Wire a random starting thickness
	thickness = randi() % 5 + 1 #Sets thickness to a random number between 1 and 5
	$Stroke.width = thickness * WIDTH_SCALE
	
	# Attempting to vary color by thickness, but might not work bc of shader?
	#var new_red := Color(1, 1 - (thickness*0.08), 1 - (thickness*0.08), 1)
	#$Stroke.set_default_color(new_red)

func set_nodes(in_node: TestNode, out_node: TestNode):
	_in_node = in_node
	_out_node = out_node
	var start = _in_node.position
	var end = _out_node.position
	connecting_letters.append(in_node.letter)
	connecting_letters.append(out_node.letter)
	update(start,end)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if (done>.99):
		update(_in_node.position, _out_node.position)
	pass
	
func update(start: Vector2, end: Vector2):
	$Stroke.width = thickness * WIDTH_SCALE  # Update stroke width based on thickness
	
	var offset = 10*Vector2.from_angle(90+start.direction_to(end).angle())
	$Stroke.set_point_position(0,start)
	$Stroke.set_point_position(1,end)
	$Hitbox.polygon = PackedVector2Array([start+offset, end + offset, end -offset, start - offset])
	
	
func pop_in(t:float):
	update(_in_node.position, _in_node.position+ t*(_out_node.position-_in_node.position))
	done = t

func get_start():
	return _in_node

func get_end():
	return _out_node
	
func get_thickness():
	return thickness
	
func set_thickness(width: int):
	thickness = width
	
func increment_thickness():
	if thickness < 5:
		thickness += 1
	pass
	
func decrement_thickness():
	if thickness > 1:
		thickness -= 1
	pass

# Doesn't take care of the duplicate letters edge case, but could add that
func check_connecting_letters(letter1: String, letter2: String):
	if connecting_letters.has(letter1) && connecting_letters.has(letter2):
		return true
	return false

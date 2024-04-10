extends AnimatableBody2D

var _from
var _to
var hue = randf()
var sat = 1
var done = 0.0
var connecting_letters: Array[String] = []
var thickness: float = 1
const WIDTH_SCALE: int = 3
const MAX_THICKNESS: int = 7
var not_scored = true

# Called when the node enters the scene tree for the first time.
func _ready():
	thickness = randi() % 4 + 4
	color()

func set_nodes(from, to):
	_from = from
	_to = to
	var start = from.position
	var end = to.position
	from.add_outgoing(self)
	to.add_incoming(self)
	connecting_letters.append(_from.get_letter())
	connecting_letters.append(_to.get_letter())
	update(start,end)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	color()
	if (done>.99):
		update(_from.position, _to.position)
	pass
	
func update(start: Vector2, end: Vector2):
	$Stroke.width = clamp(thickness * WIDTH_SCALE, 5, 20)
	$Stroke.set_point_position(0,start)
	$Stroke.set_point_position(1,end)
	
func color():
	$Stroke.set_default_color(Color.from_ok_hsl(hue, sat, .5 + thickness*.03))

func pop_in(t:float):
	update(_from.position, _from.position+ t*(_to.position-_from.position))
	done = t

func get_start():
	return _from

func get_end():
	return _to
	
func get_thickness():
	return thickness
	
func set_thickness(width: float):
	thickness = width
	
func decay(delta, score):
	var decrement = delta*.01*randf()*sqrt(score)
	if not_scored:
		decrement*=1.5
	thickness -= decrement
	if thickness< 0:
		return true
	return false
	
func increment_thickness():
	thickness +=1
	if !not_scored:
		thickness+=1
	thickness = min(thickness,MAX_THICKNESS)
	
func decrement_thickness():
	if thickness > 1:
		thickness -= 1
	pass

func check_connecting_letters(letter1: String, letter2: String):
	if connecting_letters.has(letter1) && connecting_letters.has(letter2) && letter1!=letter2:
		return true
	return false

func snap():
	_from.remove_outgoing(self)
	_to.remove_incoming(self)

func score_wire():
	var s = not_scored
	not_scored = false
	return s

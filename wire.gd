extends AnimatableBody2D

var _in_node: TestNode	
var _out_node: TestNode
var done = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func set_nodes(in_node: TestNode, out_node: TestNode):
	_in_node = in_node
	_out_node = out_node
	var start = _in_node.position
	var end = _out_node.position
	update(start,end)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if (done):
		update(_in_node.position, _out_node.position)
	pass
	
func update(start: Vector2, end: Vector2):
	var offset = 10*Vector2.from_angle(90+start.direction_to(end).angle())
	$Stroke.set_point_position(0,start)
	$Stroke.set_point_position(1,end)
	$Hitbox.polygon = PackedVector2Array([start+offset, end + offset, end -offset, start - offset])
	pass
	
func pop_in(t:float):
	update(_in_node.position, _in_node.position+ t*(_out_node.position-_in_node.position))
	
func popped_in():
	done = true

func get_start():
	return _in_node

func get_end():
	return _out_node

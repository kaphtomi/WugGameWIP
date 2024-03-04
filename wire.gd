extends AnimatableBody2D

var _inNode: TestNode	
var _outNode: TestNode
var done = false

# Called when the node enters the scene tree for the first time.
func _ready():
	
	
	#var originPos = _originNode.position
	#var destPos = _destinationNode.position

	pass # Replace with function body.

func set_nodes(inNode: TestNode, outNode: TestNode):
	_inNode = inNode
	_outNode = outNode
	var start = _inNode.position
	var end = _outNode.position
	update(start,end)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if (done):
		update(_inNode.position, _outNode.position)
	pass
	
func update(start: Vector2, end: Vector2):
	var _offset = 10*Vector2.from_angle(90+start.direction_to(end).angle())
	$Stroke.set_point_position(0,start)
	$Stroke.set_point_position(1,end)
	#$Hitbox.polygon = PackedVector2Array([start+offset, end + offset, end -offset, start - offset])
	pass
	
func pop_in(t:float):
	update(_inNode.position, _inNode.position+ t*(_outNode.position-_inNode.position))
	
func popped_in():
	done = true

func get_start():
	return _inNode

func get_end():
	return _outNode

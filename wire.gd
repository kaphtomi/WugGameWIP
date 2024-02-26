extends AnimatableBody2D

var _inNode: TestNode
var _outNode: TestNode

# Called when the node enters the scene tree for the first time.
func _ready():
	
	
	#var originPos = _originNode.position
	#var destPos = _destinationNode.position

	pass # Replace with function body.

func set_nodes(inNode: TestNode, outNode: TestNode):
	_inNode = inNode
	_outNode = outNode

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var start = _inNode.position
	var end = _outNode.position
	var offset = 10*Vector2.from_angle(90+start.direction_to(end).angle())
	$Stroke.set_point_position(0,start)
	$Stroke.set_point_position(1,end)
	$Hitbox.polygon = PackedVector2Array([start+offset, end + offset, end -offset, start - offset])
	pass

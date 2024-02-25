extends AnimatableBody2D

var _originNode: TestNode
var _destinationNode: TestNode

# Called when the node enters the scene tree for the first time.
func _ready():
	#var originPos = _originNode.position
	#var destPos = _destinationNode.position

	pass # Replace with function body.

func set_nodes(originNode: TestNode, destNode: TestNode):
	var targetAngle = originNode.position.angle_to_point(destNode.position)
	var distance = originNode.position.distance_to(destNode.position)
	var scaleVector = Vector2(distance/124, 1)
	transform = Transform2D(targetAngle, scaleVector, 0, originNode.position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass

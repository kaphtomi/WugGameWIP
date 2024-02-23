extends Node

var rng = RandomNumberGenerator.new()

const alpha = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

# Called when the node enters the scene tree for the first time.
func _ready():
	var size = get_viewport().size
	#$TestNode.set_position(Vector2(rng.randi_range(0, size.x), rng.randi_range(0, size.y)))
	#$TestNode2.set_position(Vector2(rng.randi_range(0, size.x), rng.randi_range(0, size.y)))
	#$TestNode3.set_position(Vector2(rng.randi_range(0, size.x), rng.randi_range(0, size.y)))
	#$TestNode4.set_position(Vector2(rng.randi_range(0, size.x), rng.randi_range(0, size.y)))
	#$TestNode5.set_position(Vector2(rng.randi_range(0, size.x), rng.randi_range(0, size.y)))
#
	#$TestNode.change_text(alpha[rng.randi_range(0, 25)])
	#$TestNode2.change_text(alpha[rng.randi_range(0, 25)])
	#$TestNode3.change_text(alpha[rng.randi_range(0, 25)])
	#$TestNode4.change_text(alpha[rng.randi_range(0, 25)])
	#$TestNode5.change_text(alpha[rng.randi_range(0, 25)])

	$TestNode.change_text("A")
	$TestNode2.change_text("J")
	$TestNode3.change_text("Q")
	$TestNode4.change_text("Y")
	$TestNode5.change_text("L")
	$TestNode6.change_text("M")
	$TestNode7.change_text("O")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

extends Node2D

var rng = RandomNumberGenerator.new()

const alpha = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

# Called when the node enters the scene tree for the first time.
func _ready():
	var size = get_viewport().size
#
	#$TestNode.change_text(alpha[rng.randi_range(0, 25)])
	#$TestNode2.change_text(alpha[rng.randi_range(0, 25)])
	#$TestNode3.change_text(alpha[rng.randi_range(0, 25)])
	#$TestNode4.change_text(alpha[rng.randi_range(0, 25)])
	#$TestNode5.change_text(alpha[rng.randi_range(0, 25)])

	$TestNode.change_text("1")
	$TestNode2.change_text("2")
	$TestNode3.change_text("3")
	$TestNode4.change_text("4")
	$TestNode5.change_text("5")
	$TestNode6.change_text("6")
	$TestNode7.change_text("7")
	$TestNode8.change_text("8")
	$TestNode9.change_text("9")
	
	$Wire.set_nodes($TestNode, $TestNode8)
	$Wire2.set_nodes($TestNode, $TestNode4)
	$Wire3.set_nodes($TestNode4, $TestNode6)
	$Wire4.set_nodes($TestNode4, $TestNode5)
	$Wire5.set_nodes($TestNode5, $TestNode3)
	$Wire6.set_nodes($TestNode9, $TestNode2)
	$Wire7.set_nodes($TestNode6, $TestNode9)
	$Wire8.set_nodes($TestNode8, $TestNode7)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

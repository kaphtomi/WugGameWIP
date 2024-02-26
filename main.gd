extends Node2D

var rng = RandomNumberGenerator.new()

const alpha = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
const alphabest = "eeeeeeeeeeeetttttttttaaaaaaaaooooooiiiiiiinnnnnnsssssshhhhhhrrrrrrddddllllcccuuuummmwwffggyyppbbvkjxqz"

# Called when the node enters the scene tree for the first time.
func _ready():
	var size = get_viewport().size
#
	#$TestNode.change_text(alpha[rng.randi_range(0, 25)])
	#$TestNode2.change_text(alpha[rng.randi_range(0, 25)])
	#$TestNode3.change_text(alpha[rng.randi_range(0, 25)])
	#$TestNode4.change_text(alpha[rng.randi_range(0, 25)])
	#$TestNode5.change_text(alpha[rng.randi_range(0, 25)])


	#$TestNode.change_text("1")
	#$TestNode2.change_text("2")
	#$TestNode3.change_text("3")
	#$TestNode4.change_text("4")
	#$TestNode5.change_text("5")
	#$TestNode6.change_text("6")
	#$TestNode7.change_text("7")
	#$TestNode8.change_text("8")
	$TestNode9.change_text(alphabest[randi() % alphabest.length()])
	$TestNode.change_text(alphabest[randi() % alphabest.length()])
	$TestNode2.change_text(alphabest[randi() % alphabest.length()])
	$TestNode3.change_text(alphabest[randi() % alphabest.length()])
	$TestNode4.change_text(alphabest[randi() % alphabest.length()])
	$TestNode5.change_text(alphabest[randi() % alphabest.length()])
	$TestNode6.change_text(alphabest[randi() % alphabest.length()])
	$TestNode7.change_text(alphabest[randi() % alphabest.length()])
	$TestNode8.change_text(alphabest[randi() % alphabest.length()])
	$TestNode9.change_text(alphabest[randi() % alphabest.length()])
	
	$Wire.set_nodes($TestNode, $TestNode8)
	$Wire2.set_nodes($TestNode, $TestNode4)
	$Wire3.set_nodes($TestNode4, $TestNode6)
	$Wire4.set_nodes($TestNode4, $TestNode5)
	$Wire5.set_nodes($TestNode5, $TestNode3)
	$Wire6.set_nodes($TestNode9, $TestNode2)
	$Wire7.set_nodes($TestNode6, $TestNode9)
	$Wire8.set_nodes($TestNode8, $TestNode7)
	pop_in()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func pop_in():
	var vertices : Array = [$TestNode, $TestNode2, $TestNode3, $TestNode4, $TestNode5, $TestNode6, $TestNode7, $TestNode8, $TestNode9]
	for v in vertices:
		v.scale = Vector2.ZERO
		
		var tween = create_tween()
		tween.tween_interval(.5+randf()*.5)
		tween.tween_property(v, "scale", (1+randf()*.3)*Vector2.ONE, .2)
		tween.tween_property(v, "scale", Vector2.ONE, randf()*.1)
		tween.play()
	
	var edges : Array = [$Wire, $Wire2, $Wire3, $Wire4, $Wire5, $Wire6, $Wire7, $Wire8]
	for v in edges:
		v.pop_in(0)
		
		var tween = create_tween()
		tween.tween_interval(.9+randf()*.3)
		tween.tween_method(v.pop_in,0.0,1.0,.3)
		tween.play()

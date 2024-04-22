extends CanvasLayer

var default_cursor: Image = load("res://assets/cursor.png").get_image()
var pressed_cursor: Image = load("res://assets/icon.svg").get_image()
var base_cursor_size = max(default_cursor.get_size().x, default_cursor.get_size().y)
const HOTSPOT = Vector2(10,0)
var current_image
var tween


# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_custom_mouse_cursor(ImageTexture.create_from_image(default_cursor))
	current_image = default_cursor
	update_cursor(0.25)
	tween = get_tree().create_tween().set_loops()
	pulse_cursor()


func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			current_image = pressed_cursor
		else:
			current_image = default_cursor
	if event is InputEventMouseMotion:
		tween.kill()
	
	update_cursor(0.25)


func update_cursor(size_scale):
	var image = Image.new()
	image.copy_from(current_image)
	image.resize(base_cursor_size * size_scale, base_cursor_size * size_scale, Image.INTERPOLATE_NEAREST) 
	var texture = ImageTexture.create_from_image(image)
	Input.set_custom_mouse_cursor(texture, Input.CURSOR_ARROW, HOTSPOT)
	

func pulse_cursor():
	tween.tween_method(update_cursor, 0.25, 0.75, 1)
	tween.tween_method(update_cursor, 0.75, 0.25, 1)
	
	

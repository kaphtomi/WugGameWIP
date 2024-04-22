extends CanvasLayer

var default_cursor: Image = load("res://assets/cursor.png").get_image()
var pressed_cursor: Image = load("res://assets/icon.svg").get_image()
var base_cursor_size = max(default_cursor.get_size().x, default_cursor.get_size().y)
const HOTSPOT = Vector2(10,0)
var current_image


# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_custom_mouse_cursor(ImageTexture.create_from_image(default_cursor))
	current_image = default_cursor
	update_cursor(0.25)


func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			current_image = pressed_cursor
		else:
			current_image = default_cursor
	update_cursor(0.25)


func update_cursor(size_scale):
	current_image.resize(base_cursor_size * size_scale, base_cursor_size * size_scale, Image.INTERPOLATE_NEAREST) 
	var texture = ImageTexture.create_from_image(current_image)
	Input.set_custom_mouse_cursor(texture, Input.CURSOR_ARROW, HOTSPOT)

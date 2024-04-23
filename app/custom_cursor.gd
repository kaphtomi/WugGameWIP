extends CanvasLayer

var default_cursor: Image = load("res://assets/cursor/cursor_arrow.png").get_image()
var pressed_cursor: Image = load("res://assets/cursor/cursor_pressed.png").get_image()
var base_cursor_size = max(default_cursor.get_size().x, default_cursor.get_size().y)
const HOTSPOT = Vector2(5,12) # Where the "clicky-point" is in the custom image
var current_image


# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_custom_mouse_cursor(ImageTexture.create_from_image(default_cursor))
	current_image = default_cursor
	update_cursor(GlobalVariables.cursor_base_scale)

# Changes the image of the cursor based on whether the mouse is pressed
func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			current_image = pressed_cursor
		else:
			current_image = default_cursor
		update_cursor(GlobalVariables.cursor_base_scale) 

# Updates the image size of the cursor based on a scale number
func update_cursor(size_scale):
	var image = Image.new()
	image.copy_from(current_image)
	image.resize(base_cursor_size * size_scale, base_cursor_size * size_scale, Image.INTERPOLATE_CUBIC) 
	var texture = ImageTexture.create_from_image(image)
	Input.set_custom_mouse_cursor(texture, Input.CURSOR_ARROW, HOTSPOT)

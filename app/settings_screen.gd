extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_texture_button_pressed():
	get_tree().change_scene_to_file("res://app/start_screen/start_screen.tscn")

func _on_music_button_pressed():
	GlobalAudio.stream_paused = !GlobalAudio.stream_paused


	


func _on_check_box_toggled(toggled_on):
	GlobalAudio.stream_paused = !GlobalAudio.stream_paused


func _on_check_button_toggled(toggled_on):
	GlobalAudio.stream_paused = !GlobalAudio.stream_paused

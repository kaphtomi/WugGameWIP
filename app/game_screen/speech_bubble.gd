extends Control
#This adds the words to a bubble and expands the bubble as the text increases.
#Followed tutorial by Rungeon on YoutTube 
var bubble_text = "Make connections by typing in connecting letters! Press enter to submit."
var bubble_text_length = 0
var bubble_text_index = 0
var current_text = ""
var can_shrink = true 
var snooze_text = "I'm getting sleepy... Zzzz"

@onready var lbltext = get_node("VBoxContainer/Label")
@onready var ninerect = get_node("VBoxContainer/Label/NinePatchRect")
@onready var timer = get_node("Timer")

var do_close = false
# Called when the node enters the scene tree for the first time.
func _ready():
	bubble_text_length = bubble_text.length()
	timer.start(1)
	
	pass # Replace with function body.


#Hides the bubble once the timer runs out
func _on_timer_timeout():
	if(!do_close):
		current_text += bubble_text[bubble_text_index]
		lbltext.text = current_text
		
		if(bubble_text_index < bubble_text_length -1):
			timer.start(0.04)
			bubble_text_index += 1
		else:
			if(!do_close):
				do_close = true
				timer.start(1)
	else:
		if(bubble_text_length > 0):
			current_text.erase(bubble_text_length -1,1)
			lbltext.text = current_text
			bubble_text_length -= 1
			
			
			timer.start(0.04)
		else:
			queue_free()
	
	





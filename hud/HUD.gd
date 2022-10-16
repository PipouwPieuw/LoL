extends Node2D

onready var dialogBox = $DialogBox

var textDuration = 0
var countdown = false

func _ready():
	add_to_group('hud')

func displayText(text):
	dialogBox.text = text
	textDuration = 3
	if(!countdown):
		textCoundown()

func textCoundown():
	countdown = true
	while textDuration > 0:
		yield(get_tree().create_timer(1), "timeout")
		textDuration -= 1
	dialogBox.text = ''
	countdown = false

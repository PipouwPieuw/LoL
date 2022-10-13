extends Node2D

onready var dialogBox = $DialogBox

func _ready():
	add_to_group('hud')

func displayText(text):
	dialogBox.text = text
	yield(get_tree().create_timer(3), "timeout")
	dialogBox.text = ''

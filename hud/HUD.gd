extends Node2D

onready var dialogBox = $DialogBox

func _ready():
	add_to_group('hud')

func displayText(text):
	dialogBox.text = text

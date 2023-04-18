extends Node2D

var data = {}

onready var portrait = $Portrait

func _ready():
	add_to_group('party')
	portrait.texture = load("res://assets/sprites/portraits/char" + data.attributes.id + ".png")

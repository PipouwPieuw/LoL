extends Node2D

onready var background = $Background
onready var close = $Close

var data = {}
var _err

func _ready():
	add_to_group('chardetails')
	visible = false
	background.texture = load("res://assets/sprites/hud/inventory" + data.attributes.inventoryId + ".png")
	_err = close.connect("input_event", self, "close_details")

func display_details(id):
	if id == data.attributes.id:
		get_tree().call_group('inputs', 'set_move', false)
		visible = true
	else:
		visible = false

func close_details(_viewport, event, _shape_idx):
	if event is InputEventMouseButton  and event.button_index == BUTTON_LEFT and event.pressed:
		visible = false
		get_tree().call_group('inputs', 'set_move', true)

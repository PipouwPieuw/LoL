extends Node2D

onready var expandable = $Expandable
onready var bottom = $Bottom
onready var textContainer = $Textcontainer
onready var close = $Close

var boxTextScene = preload("res://hud/BoxText.tscn")
var textDuration = 0
var countdown = false
var expandHeight = 36
var expanded = false
var _err

func _ready():
	add_to_group('dialogbox')
	_err = close.connect("input_event", self, "close_box")

func displayText(text):
	get_tree().call_group('boxtext', 'queue_free')
	var boxTextInstance = boxTextScene.instance()
	textContainer.add_child(boxTextInstance)
	boxTextInstance.displayText(text)

func expand_box():
	if(!expanded):
		get_tree().call_group('hud', 'toggle_hud', false)
		var counter = 0
		while counter < expandHeight:
			bottom.position.y += 2
			expandable.scale.y += 2
			counter += 2
			yield(get_tree().create_timer(.02), "timeout")
		expanded = true
		get_tree().call_group('boxtext', 'set_visible', true)
		close.visible = true

func unexpand_box():
	if(expanded):
		get_tree().call_group('boxtext', 'queue_free')
		close.visible = false
		var counter = expandHeight
		while counter > 0:
			bottom.position.y -= 2
			expandable.scale.y -= 2
			counter -= 2
			yield(get_tree().create_timer(.02), "timeout")
		expanded = false
		get_tree().call_group('hud', 'toggle_hud', true)

func close_box(_viewport, event, _shape_idx):
	if event is InputEventMouseButton  and event.button_index == BUTTON_LEFT and event.pressed:
		unexpand_box()

extends Area2D

var triggerType = ''
var effect = ''
var targetCell = -1
var text = []
var invalidText = ''
var acceptedItems = []
var attachedNode

var _err

func _ready():
	if triggerType == 'click':
		_err = connect("input_event", self, "sendInteraction")

func sendInteraction(_viewport, event, _shape_idx):
	if event is InputEventMouseButton  and event.button_index == BUTTON_LEFT and event.pressed:
		var args
		if effect == 'toggleDoor':
			args = targetCell
		elif effect == 'displayText':
			args = text[0]
		elif effect == 'keyhole':
			args = [text[0], invalidText, targetCell, acceptedItems]
		get_tree().call_group('controller', effect, args, self)

func updateText():
	text.push_back(text.pop_front())

func disconnect_signal():
		disconnect("input_event", attachedNode, "sendInteraction")

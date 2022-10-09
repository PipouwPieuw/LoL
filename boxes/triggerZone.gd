extends Area2D

var triggerType = ''
var effect = ''
var targetCell = -1
var text = ''
var attachedNode

var _err

func _ready():
	var args
	if effect == 'toggleDoor':
		args = [effect, targetCell]
	elif effect == 'displayText':
		args = [effect, text]
	if triggerType == 'click':
		_err = connect("input_event", attachedNode, "sendInteraction", args)

func disconnect_signal():
		disconnect("input_event", attachedNode, "sendInteraction")

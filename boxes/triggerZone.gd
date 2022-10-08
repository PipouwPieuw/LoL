extends Area2D

var triggerType = ''
var effect = ''
var targetCell = -1
var attachedNode

var _err

func _ready():
	if triggerType == 'click':
		_err = connect("input_event", attachedNode, "sendInteraction", [effect, targetCell])

func disconnect_signal():
		disconnect("input_event", attachedNode, "sendInteraction")

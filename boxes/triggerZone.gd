extends Area2D

var zoneData = {}

var _err

func _ready():
	if zoneData.triggerType == 'click':
		_err = connect("input_event", self, "sendInteraction")

func sendInteraction(_viewport, event, _shape_idx):
	if event is InputEventMouseButton  and event.button_index == BUTTON_LEFT and event.pressed:
		var args
		if zoneData.effect == 'toggleDoor':
			args = zoneData.targetCell
		elif zoneData.effect == 'displayText':
			args = zoneData.text[0]
		elif zoneData.effect == 'keyhole':
			args = zoneData
		get_tree().call_group('controller', zoneData.effect, args, self)

func updateText():
	zoneData.text.push_back(zoneData.text.pop_front())

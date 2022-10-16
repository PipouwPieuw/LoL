extends Area2D

export(String, "Left", "Right") var direction

var _err

func _ready():
	$Sprite.texture = load('res://assets/sprites/hud/inventory' + direction + '.png')
	_err = connect("input_event", self, "arrow_clicked")

func arrow_clicked(_target, event, _shape):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		get_tree().call_group('inventory', 'browse_inventory', direction, 'step')
	if event is InputEventMouseButton  and event.button_index == BUTTON_RIGHT and event.pressed:
		get_tree().call_group('inventory', 'browse_inventory', direction, 'line')

extends Area2D

export(String, "Left", "Right") var direction

var isActive = true
var _err

func _ready():
	add_to_group('inventoryarrows')
	$Sprite.texture = load('res://assets/sprites/hud/inventory' + direction + '.png')
	_err = connect("input_event", self, "arrow_clicked")

func arrow_clicked(_target, event, _shape):
	if isActive:
		if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
			get_tree().call_group('inventory', 'browse_inventory', direction, 'step')
		if event is InputEventMouseButton  and event.button_index == BUTTON_RIGHT and event.pressed:
			get_tree().call_group('inventory', 'browse_inventory', direction, 'line')

func set_active(mode):
	isActive = mode

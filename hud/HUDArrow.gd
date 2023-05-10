extends Area2D

export(String, "TurnLeft", "Up", "TurnRight", "Left", "Down", "Right") var direction

var _err

func _ready():
	$Sprite.texture = load('res://assets/sprites/hud/hud' + direction + '.png')
	_err = connect("input_event", self, "arrow_clicked")

func arrow_clicked(_target, event, _shape):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		get_tree().call_group('inputs', 'move', direction.to_lower(), self)

func darken():
	$Sprite.modulate = Color(.5,.5,.5);
	yield(get_tree().create_timer(.1), "timeout")
	$Sprite.modulate = Color(1,1,1);

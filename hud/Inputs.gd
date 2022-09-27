extends Node2D

func _ready():
	pass

func _physics_process(_delta):
	if Input.is_action_just_pressed('ui_up'):
		get_tree().call_group('map', 'update_position', 'up')
	if Input.is_action_just_pressed('ui_down'):
		get_tree().call_group('map', 'update_position', 'down')
	if Input.is_action_just_pressed('ui_right'):
		get_tree().call_group('map', 'update_position', 'right')
	if Input.is_action_just_pressed('ui_left'):
		get_tree().call_group('map', 'update_position', 'left')

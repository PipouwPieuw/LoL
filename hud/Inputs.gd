extends Node2D

func _ready():
	pass

func _physics_process(_delta):
	if Input.is_action_just_pressed('ui_cancel'):
		get_tree().quit()
	if Input.is_action_just_pressed('ui_up'):
		get_tree().call_group('controller', 'check_move', 'up')
	if Input.is_action_just_pressed('ui_down'):
		get_tree().call_group('controller', 'check_move', 'down')
	if Input.is_action_just_pressed('ui_right'):
		get_tree().call_group('controller', 'check_move', 'right')
	if Input.is_action_just_pressed('ui_left'):
		get_tree().call_group('controller', 'check_move', 'left')
	if Input.is_action_just_pressed('ui_turn_right'):
		get_tree().call_group('controller', 'change_direction', 'turnright')
	if Input.is_action_just_pressed('ui_turn_left'):
		get_tree().call_group('controller', 'change_direction', 'turnleft')

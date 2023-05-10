extends Node2D

onready var arrowTurnLeft = $TurnLeft
onready var arrowUp = $Up
onready var arrowTurnRight = $TurnRight
onready var arrowLeft = $Left
onready var arrowDown = $Down
onready var arrowRight = $Right
onready var disabledSprite = $DisabledSprite

var canMove = true

func _ready():
	add_to_group('inputs')

func _physics_process(_delta):
	if Input.is_action_just_pressed('ui_cancel'):
		get_tree().quit()
	if canMove:
		if Input.is_action_just_pressed('ui_up'):
			arrowUp.darken()
			get_tree().call_group('controller', 'check_move', 'up')
		if Input.is_action_just_pressed('ui_down'):
			arrowDown.darken()
			get_tree().call_group('controller', 'check_move', 'down')
		if Input.is_action_just_pressed('ui_right'):
			arrowRight.darken()
			get_tree().call_group('controller', 'check_move', 'right')
		if Input.is_action_just_pressed('ui_left'):
			arrowLeft.darken()
			get_tree().call_group('controller', 'check_move', 'left')
		if Input.is_action_just_pressed('ui_turn_right'):
			arrowTurnRight.darken()
			get_tree().call_group('controller', 'change_direction', 'turnright')
		if Input.is_action_just_pressed('ui_turn_left'):
			arrowTurnLeft.darken()
			get_tree().call_group('controller', 'change_direction', 'turnleft')

func set_move(mode):
	canMove = mode
	disabledSprite.visible = !mode
	

# Move function called by move arrows
func move(direction, arrow):
	if canMove:
		arrow.darken()
		if 'turn' in direction:
			get_tree().call_group('controller', 'change_direction', direction)
		else:
			get_tree().call_group('controller', 'check_move', direction)

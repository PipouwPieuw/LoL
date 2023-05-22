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
		get_tree().call_group('controller', 'process_escape_action')
	if Input.is_action_just_pressed('ui_accept'):
		get_tree().call_group('controller', 'process_accept_action')
	if canMove:
		if Input.is_action_just_pressed('ui_up'):
			get_tree().call_group('controller', 'queue_input', 'up')
		if Input.is_action_just_pressed('ui_down'):
			get_tree().call_group('controller', 'queue_input', 'down')
		if Input.is_action_just_pressed('ui_right'):
			get_tree().call_group('controller', 'queue_input', 'right')
		if Input.is_action_just_pressed('ui_left'):
			get_tree().call_group('controller', 'queue_input', 'left')
		if Input.is_action_just_pressed('ui_turn_right'):
			get_tree().call_group('controller', 'queue_input', 'turnright')
		if Input.is_action_just_pressed('ui_turn_left'):
			get_tree().call_group('controller', 'queue_input', 'turnleft')

func set_move(mode):
	canMove = mode
	disabledSprite.visible = !mode
	if(!mode):
		get_tree().call_group('controller', 'clear_inputs')

# Move function called by move arrows
func move(direction):
	if canMove:
		get_tree().call_group('controller', 'queue_input', direction)

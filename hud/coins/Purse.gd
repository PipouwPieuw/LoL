extends Node2D

onready var amount = $Amount
onready var stacks = $Stacks

var coins = 0
var coinStacks = []
var _err

func _ready():
	add_to_group('purse')
	_err = connect('input_event', self, 'display_amount')
	coinStacks = stacks.get_children()

func set_amount(val, animate = true):
	if val == coins:
		return
	if animate:
		animate_number(coins, val, amount)
		get_tree().call_group('audiostream', 'play_sound', 'hud', 'money')
	else:
		for i in val:
			display_sprite(coins < val)
		amount.text = str(val)
	coins = val
	get_tree().call_group('controller', 'set_coins', val)
	
func animate_number(baseValue, targetValue, label):
	var increment = targetValue - baseValue if baseValue < targetValue else baseValue - targetValue
	var operator = 1 if baseValue < targetValue else -1
	var counter = baseValue
	if operator > 0:
		while(counter < baseValue + increment):
			counter = clamp(counter + operator, baseValue, baseValue + increment)
			label.text = str(counter)
			if counter > 0 and counter <= 60:
				display_sprite(true)
			yield(get_tree().create_timer(0.01), "timeout")
	else:
		while(counter > baseValue - increment):
			counter = clamp(counter + operator, baseValue - increment, baseValue)
			label.text = str(counter)
			if counter >= 0 and counter < 60:
				display_sprite(false)
			yield(get_tree().create_timer(0.01), "timeout")

func display_sprite(mode):
	randomize()
	coinStacks.shuffle()
	var counter = 0
	while(mode and coinStacks[counter].coinsShown == 12) or (!mode and coinStacks[counter].coinsShown == 0):
		counter += 1
	coinStacks[counter].display_coin(mode)

func display_amount(_viewport, event, _shape_idx):
	if event is InputEventMouseButton  and event.button_index == BUTTON_LEFT and event.pressed:
		var plural = 's' if coins > 1 else ''
		var text = 'You currently have ' + str(coins) + ' silver crown' + plural + '.'
		get_tree().call_group('audiostream', 'play_sound', 'hud', 'grabitem')
		get_tree().call_group('dialogbox', 'displayText', text)

func toggle(mode):
	visible = mode

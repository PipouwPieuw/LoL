extends Node2D

onready var amount = $Amount

var coins = 0

func _ready():
	add_to_group('coins')

func set_amount(val):
	animate_number(coins, val, amount)
	coins = val
	get_tree().call_group('controller', 'set_coins', val)
	
func animate_number(baseValue, targetValue, label):
	var increment = targetValue - baseValue if baseValue < targetValue else baseValue - targetValue
	var operator = 1 if baseValue < targetValue else -1	
	var counter = baseValue + operator
	if operator > 0:
		while(counter < baseValue + increment):
			counter = clamp(counter + operator, baseValue, baseValue + increment)
			label.text = str(counter)
			yield(get_tree().create_timer(0.01), "timeout")
	else:
		while(counter > baseValue - increment):
			counter = clamp(counter + operator, baseValue - increment, baseValue)
			label.text = str(counter)
			yield(get_tree().create_timer(0.01), "timeout")

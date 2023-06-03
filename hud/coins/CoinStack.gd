extends Node2D

onready var coinScene = preload('res://hud/coins/Coin.tscn')

var coinAmount = 12
var coins = []
var coinsReverse = []
var coinsShown = 0

func _ready():
	add_to_group('coinstack')
	for i in coinAmount:
		var coinInstance = coinScene.instance()
		coinInstance.position.y = -i
		add_child(coinInstance)
	coins = get_children()
	coinsReverse = get_children()
	coinsReverse.invert()

func display_coin(mode):
	var order = coins
	var operator = 1
	if !mode:
		order = coinsReverse
		operator = -1
	for coin in order:
		if coin.visible != mode:
			coin.visible = mode
			coinsShown += operator
			break

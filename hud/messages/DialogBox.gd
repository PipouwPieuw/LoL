extends Node2D

onready var expandable = $Expandable
onready var bottom = $Bottom
onready var textContainer = $Textcontainer
onready var shopButtons = $ShopButtons
onready var shopAccept = $ShopButtons/ShopAccept
onready var shopRefuse = $ShopButtons/ShopRefuse
onready var close = $Close
onready var boxTextScene = preload('res://hud/messages/BoxText.tscn')

var textDuration = 0
var countdown = false
var expandHeight = 36
var expanded = false
var _err

func _ready():
	add_to_group('dialogbox')
	_err = shopAccept.connect("input_event", self, "shop_accept")
	_err = shopRefuse.connect("input_event", self, "shop_refuse")
	_err = close.connect("input_event", self, "box_action")

func displayText(text, expand = false, type = 'default'):
	get_tree().call_group('boxtext', 'set_destroy')
	var boxTextInstance = boxTextScene.instance()
	textContainer.add_child(boxTextInstance)
	if type == 'error':
		 boxTextInstance.set("custom_colors/font_color", Color('#ee2521'))
	boxTextInstance.displayText(text, expand, !expanded)

func expand_box(mode = 'default'):
	if(!expanded):
		get_tree().call_group('hud', 'toggle_hud', false)
		var counter = 0
		while counter < expandHeight:
			bottom.position.y += 2
			expandable.scale.y += 2
			counter += 2
			yield(get_tree().create_timer(.02), "timeout")
		expanded = true
		get_tree().call_group('boxtext', 'set_visible', true)
		if not ['scene'].has(mode):
			get_tree().call_group('inventory', 'set_active', false)
			close.visible = true

func unexpand_box():
	if(expanded):
		get_tree().call_group('boxtext', 'queue_free')
		close.visible = false
		var counter = expandHeight
		while counter > 0:
			bottom.position.y -= 2
			expandable.scale.y -= 2
			counter -= 2
			yield(get_tree().create_timer(.02), "timeout")
		expanded = false
		get_tree().call_group('hud', 'toggle_hud', true)
		get_tree().call_group('inventory', 'set_active', true)
		set_close_label('More')

func display_shop(text):
	displayText(text, false, 'default')
	shopButtons.visible = true

func set_close_label(newText):
	close.find_node('Label').text = newText

func box_action(_viewport, event, _shape_idx):
	if event is InputEventMouseButton  and event.button_index == BUTTON_LEFT and event.pressed:
		get_tree().call_group('boxtext', 'display_next_lines')

func shop_accept(_viewport, event, _shape_idx):
	if event is InputEventMouseButton  and event.button_index == BUTTON_LEFT and event.pressed:
		get_tree().call_group('controller', 'buy_tem')
		shopButtons.visible = false

func shop_refuse(_viewport, event, _shape_idx):
	if event is InputEventMouseButton  and event.button_index == BUTTON_LEFT and event.pressed:
		get_tree().call_group('boxtext', 'set_destroy')
		get_tree().call_group('controller', 'discard_shop')
		shopButtons.visible = false

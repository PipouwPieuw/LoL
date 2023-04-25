extends Node2D

onready var portrait = $Portrait
onready var trigger = $Trigger
onready var gauges = $Gauges
onready var attack = $Attack
onready var spell = $Spell
onready var activeFrame = $ActiveFrame

var data = {}
var charId
var blinkTimer = 0
var blinkTimerLimit = randi() % 5 + 1
var blinking = false
var _err

func _ready():
	add_to_group('party')
	charId = data.attributes.id
	hide_active_frame('all')
	portrait.texture = load("res://assets/sprites/portraits/char" + charId + ".png")
	_err = trigger.connect("input_event", self, "trigger_event")
	_err = gauges.connect("input_event", self, "gauges_event")
	_err = attack.connect("input_event", self, "attack_event")
	_err = spell.connect("input_event", self, "spell_event")

func _physics_process(delta):
	blinkTimer += delta
	if(blinkTimer >= blinkTimerLimit and not blinking):
		blinking = true
		blink()
		

func trigger_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton  and event.button_index == BUTTON_LEFT and event.pressed:
		set_active_frame()
		get_tree().call_group('viewport', 'hide_viewport')
		get_tree().call_group('chardetails', 'display_details', charId)

func gauges_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton  and event.button_index == BUTTON_LEFT and event.pressed:
		set_active_frame()
		print("DISPLAY VITALS !")

func attack_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton  and event.button_index == BUTTON_LEFT and event.pressed:
		set_active_frame()
		print("ATTACK !")
		print(data)

func spell_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton  and event.button_index == BUTTON_LEFT and event.pressed:
		set_active_frame()
		print("CAST SPELL !")

func set_active_frame():
	get_tree().call_group('party', 'hide_active_frame', charId)
	activeFrame.visible = true;

func hide_active_frame(id):
	if not id == charId or id == 'all':
		activeFrame.visible = false;

func blink():
	portrait.frame = 1
	yield(get_tree().create_timer(0.2), "timeout")
	portrait.frame = 0
	blinkTimer = 0
	randomize()
	blinkTimerLimit = randi() % 5 + 1
	blinking = false

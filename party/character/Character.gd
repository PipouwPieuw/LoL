extends Node2D

onready var portrait = $Portrait
onready var trigger = $Trigger
onready var gauges = $Gauges
onready var attack = $Attack
onready var spell = $Spell

var data = {}
var _err

func _ready():
	add_to_group('party')
	portrait.texture = load("res://assets/sprites/portraits/char" + data.attributes.id + ".png")
	_err = trigger.connect("input_event", self, "trigger_event")
	_err = gauges.connect("input_event", self, "gauges_event")
	_err = attack.connect("input_event", self, "attack_event")
	_err = spell.connect("input_event", self, "spell_event")

func trigger_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton  and event.button_index == BUTTON_LEFT and event.pressed:
		get_tree().call_group('chardetails', 'display_details', data.attributes.id)

func gauges_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton  and event.button_index == BUTTON_LEFT and event.pressed:
		print("DISPLAY VITALS !")

func attack_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton  and event.button_index == BUTTON_LEFT and event.pressed:
		print("ATTACK !")

func spell_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton  and event.button_index == BUTTON_LEFT and event.pressed:
		print("CAST SPELL !")

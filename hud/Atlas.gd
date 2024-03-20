extends Area2D

onready var animation = $Animation
onready var sprite = $Sprite
onready var shape = $Shape

var _err
var active = false
var zoneData = {}

func _ready():
	add_to_group('atlas')
	_err = animation.connect("animation_finished", self, "animation_ended")
	_err = self.connect("input_event", self, "show_map")

func display_atlas(args):
	get_tree().call_group('inputs', 'set_move', false)
	zoneData = args
	get_tree().call_group('audiostream', 'play_sound', 'hud', 'atlas')
	animation.play()
	active = true

func animation_ended():
	animation.visible = false
	sprite.visible = true
	shape.disabled = false
	get_tree().call_group('dialogbox', 'displayText', zoneData.text)
	get_tree().call_group('controller', 'replace_wall', zoneData.attachedWall, zoneData.replacementWall)
	get_tree().call_group('map', 'toggle_atlas_state', true)
	get_tree().call_group('map', 'reveal_cells')
	get_tree().call_group('inputs', 'set_move', true)

func toggle(mode):
	visible = mode

func set_active(mode):
	if active:
		shape.disabled = mode
	
func show_map(_viewport, event, _shape_idx):
	if event is InputEventMouseButton  and event.button_index == BUTTON_LEFT and event.pressed:
		get_tree().call_group('inputs', 'set_move', false)
		get_tree().call_group('hud', 'toggle', false)
		get_tree().call_group('map', 'toggle', true)

func test_atlas():
	animation.visible = false
	sprite.visible = true
	shape.disabled = false

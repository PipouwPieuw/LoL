extends Node2D

onready var dialogBox = $DialogBox

func _ready():
	add_to_group('hud')

func toggle(mode):
	visible = mode

func toggle_hud(mode):
	get_tree().call_group('party', 'toggle_triggers', mode)
	get_tree().call_group('inputs', 'set_move', mode)

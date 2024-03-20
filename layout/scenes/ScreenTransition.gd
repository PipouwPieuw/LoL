extends Node2D

onready var transitionAnimation = $TransitionAnimation

var transitionTarget = 'viewport'
var transitionDelay = 0

func _ready():
	add_to_group('screentransition')

func transition(target = 'viewport', _args = {}, delay = 0):
	transitionDelay = delay
	visible = true
	transitionTarget = target
	transitionAnimation.play("fade_to_black")

func animation_finished(anim_name):
	if anim_name == 'fade_to_black':
		if transitionTarget != 'viewport':
			get_tree().call_group('viewport', 'add_scene', transitionTarget)
		else:
			get_tree().call_group('viewport', 'remove_scene')
		yield(get_tree().create_timer(transitionDelay), "timeout")
		transitionAnimation.play("fade_to_normal")
	else:
		visible = false

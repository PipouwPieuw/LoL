extends Node2D

onready var textArea = $TextArea
onready var portrait = $Portrait

var textDuration = 30
var maxLines = 5
var expandedHeight = 44
var destroy = false
var _err

func _ready():
	textArea.max_lines_visible = maxLines
	add_to_group('boxtext')

func displayText(textToDisplay, expand, setCountdown = true, sceneCallback = 'none', callSceneOnDestroy = false):
	if callSceneOnDestroy:
		_err = self.connect("tree_exiting", self, "scene_callback")
	textArea.text = textToDisplay
	if expand or (textArea.get_line_count() > 2 and get_tree().get_nodes_in_group('scene').size() == 0):
		textArea.rect_size.y = expandedHeight
		check_remaining_lines()
		get_tree().call_group('dialogbox', 'expand_box')
	elif setCountdown:
		textCoundown()
	else:
		visible = true
		if sceneCallback != 'none':
			scene_countdown(sceneCallback)

func displayTextWithPortrait(textToDisplay, charId, isScene = false):
	if isScene:
		_err = self.connect("tree_exiting", self, "scene_callback")
	portrait.texture = load('res://assets/sprites/portraits/char' + charId + '.png')
	textArea.margin_left = 40
	portrait.visible = true
	portrait.play_animation()
	textArea.text = textToDisplay
	portrait_countdown()

func textCoundown():
	if textArea.text.length() / 2.0 > textDuration:
		textDuration = textArea.text.length() / 2.0
	visible = true
	while textDuration > 0:
		yield(get_tree().create_timer(.1), "timeout")
		if destroy:
			textDuration = 0
			queue_free()
			return
		else:
			textDuration -= 1
	queue_free()

func scene_countdown(sceneCallback):
	if textArea.text.length() / 2.0 > textDuration:
		textDuration = textArea.text.length() / 2.0
	while textDuration > 0:
		yield(get_tree().create_timer(.1), "timeout")
		if destroy:
			textDuration = 0
			get_tree().call_group('scenecontainer', sceneCallback)
			return
		else:
			textDuration -= 1
	get_tree().call_group('scenecontainer', sceneCallback)

func portrait_countdown():
	textDuration = textArea.text.length() / 2.0
	visible = true
	while textDuration > 0:
		yield(get_tree().create_timer(.1), "timeout")
		if destroy:
			textDuration = 0
			portrait.stop_animation()
			return
		else:
			textDuration -= 1
	portrait.stop_animation()

func display_next_lines(isScene = false):
	if get_remaining_lines():
		if isScene:
			get_tree().call_group('dialogbox', 'toggle_scene_button', false)
			if portrait.visible:
				if portrait.playing:
					portrait.stop_animation()
				portrait.visible = false
			set_destroy()
#			yield(get_tree().create_timer(.2), "timeout")
			queue_free()
		else:
			get_tree().call_group('dialogbox', 'unexpand_box')
	else:
		textArea.lines_skipped += maxLines
		check_remaining_lines()

func check_remaining_lines():
	if get_remaining_lines():
		get_tree().call_group('dialogbox', 'set_close_label', 'Close')

func get_remaining_lines():
	return textArea.get_line_count() - textArea.lines_skipped <= maxLines

func set_destroy():
	textArea.text = ''
	destroy = true

func scene_callback():
	get_tree().call_group('scenecontainer', 'process_arrival_actions')

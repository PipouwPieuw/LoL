extends Label

var textDuration = 30
var maxLines = 5
var expandedHeight = 44
var destroy = false
var _err

func _ready():
	max_lines_visible = maxLines
	add_to_group('boxtext')

func displayText(textToDisplay, expand, setCountdown = true, sceneCallback = 'none', callSceneOnDestroy = false):
	if callSceneOnDestroy:
		_err = self.connect("tree_exiting", self, "scene_callback")
	text = textToDisplay
	if expand or (get_line_count() > 2 and get_tree().get_nodes_in_group('scene').size() == 0):
		rect_size.y = expandedHeight
		check_remaining_lines()
		get_tree().call_group('dialogbox', 'expand_box')
	elif setCountdown:
		textCoundown()
	else:
		visible = true
		if sceneCallback != 'none':
			scene_countdown(sceneCallback)

func textCoundown():
	if text.length() / 2.0 > textDuration:
		textDuration = text.length() / 2.0
	visible = true
	while textDuration > 0:
		yield(get_tree().create_timer(.1), "timeout")
		if destroy:
			textDuration = 0
		else:
			textDuration -= 1
	queue_free()

func scene_countdown(sceneCallback):
	if text.length() / 2.0 > textDuration:
		textDuration = text.length() / 2.0
	while textDuration > 0:
		yield(get_tree().create_timer(.1), "timeout")
		if destroy:
			textDuration = 0
		else:
			textDuration -= 1
	get_tree().call_group('scenecontainer', sceneCallback)

func display_next_lines(isScene = false):
	if get_remaining_lines():
		if isScene:
			get_tree().call_group('dialogbox', 'toggle_scene_button', false)
#			get_tree().call_group('scenecontainer', 'stop_speaking')
			set_destroy()
			yield(get_tree().create_timer(.1), "timeout")
			queue_free()
		else:
			get_tree().call_group('dialogbox', 'unexpand_box')
	else:
		lines_skipped += maxLines
		check_remaining_lines()

func check_remaining_lines():
	if get_remaining_lines():
		get_tree().call_group('dialogbox', 'set_close_label', 'Close')

func get_remaining_lines():
	return get_line_count() - lines_skipped <= maxLines

func set_destroy():
	text = ''
	destroy = true

func scene_callback():
	get_tree().call_group('scenecontainer', 'process_arrival_actions')

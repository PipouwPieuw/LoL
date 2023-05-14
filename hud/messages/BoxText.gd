extends Label

var textDuration = 3
var maxLines = 5
var expandedHeight = 44
var destroy = false

func _ready():
	max_lines_visible = maxLines
	add_to_group('boxtext')

func displayText(textToDisplay, expand):
	text = textToDisplay
	if expand or get_line_count() > 2:
		rect_size.y = expandedHeight
		check_remaining_lines()
		get_tree().call_group('dialogbox', 'expand_box')
	else:
		textCoundown()

func textCoundown():
	visible = true
	while textDuration > 0:
		yield(get_tree().create_timer(1), "timeout")
		if destroy:
			textDuration = 0
		else:
			textDuration -= 1
	queue_free()

func display_next_lines():
	if get_remaining_lines():
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

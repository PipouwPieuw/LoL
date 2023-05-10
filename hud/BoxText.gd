extends Label

var textDuration = 3

func _ready():
	add_to_group('boxtext')

func displayText(textToDisplay):
	text = textToDisplay
	if get_line_count() > 2:
		get_tree().call_group('dialogbox', 'expand_box')
	else:
		textCoundown()

func textCoundown():
	visible = true
	while textDuration > 0:
		yield(get_tree().create_timer(1), "timeout")
		textDuration -= 1
	queue_free()

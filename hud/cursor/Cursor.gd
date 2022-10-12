extends AnimatedSprite

func _ready():
	Input.set_custom_mouse_cursor(frames.get_frame(animation, frame), Input.CURSOR_ARROW, Vector2(frames.get_frame(animation, frame).get_width(), frames.get_frame(animation, frame).get_height()) / 2)

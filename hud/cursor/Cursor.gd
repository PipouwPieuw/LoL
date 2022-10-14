extends AnimatedSprite

const SPRITE_SIZE = 20

var displaySprite = false

func _ready():
	visible = false
	add_to_group('cursor')
#	Input.set_custom_mouse_cursor(frames.get_frame(animation, frame), Input.CURSOR_ARROW, Vector2(frames.get_frame(animation, frame).get_width(), frames.get_frame(animation, frame).get_height()) / 2)

func _process(_delta):
	if displaySprite:
		global_position = Vector2(get_global_mouse_position().x - SPRITE_SIZE / 2.0, get_global_mouse_position().y - SPRITE_SIZE / 2.0)

func show_sprite(index):
	frame = index
	displaySprite = true
	visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func hide_sprite():
	displaySprite = false
	visible = false
	Input.set_mouse_mode(Input.CURSOR_ARROW)

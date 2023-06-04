extends Sprite

var speakingFrames = [7, 8, 9, 10, 11, 12, 13]
var playing = false

func _ready():
	add_to_group('textPortrait')

func play_animation():
	playing = true
	while(playing):
		var currentFrame = speakingFrames.pop_front()
		speakingFrames.append(currentFrame)
		frame = currentFrame
		yield(get_tree().create_timer(.2), "timeout")
	frame = 0

func stop_animation():
	playing = false

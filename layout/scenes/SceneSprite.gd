extends AnimatedSprite

var hasAutoplay = false
var isPlaying = false
var isQueuing = false
var autoplayDelay = 0
var autoplayLimit = 0
var autoplayTimer = 0
var autoplayAnimations = []
var queuedAnimations = []
var _err

func _ready():
	add_to_group('sceneSprite')

func init(sprite, layout, name):
	var spriteFramesInstance = SpriteFrames.new()
	var spriteSize = Vector2(sprite.width, sprite.height)
	var animationSpriteSheet : Texture = load('assets/sprites/animations/' + layout + '/' +  name + '.png')
	if sprite.has('autoplayDelay'):
		hasAutoplay = true
		autoplayDelay = sprite.autoplayDelay
		autoplayLimit = randi() % int(autoplayDelay) + 1
#		_err = self.connect('animation_finished', self, 'end_animation_autoplay')
#	else:
	_err = self.connect('animation_finished', self, 'end_animation')
	for animationName in sprite.animations:
		var animation = sprite.animations[animationName]
		var counter = 0
		if !spriteFramesInstance.has_animation(animationName):
			spriteFramesInstance.add_animation(animationName)
			spriteFramesInstance.set_animation_speed(animationName, animation.speed)
			for x in animation.frames:
				var frame = AtlasTexture.new()
				frame.atlas = animationSpriteSheet
				frame.region = Rect2(Vector2(x, 0) * spriteSize, spriteSize)
				spriteFramesInstance.add_frame(animationName, frame, counter)
				counter += 1
		if animation.has('autoplay') and animation.autoplay:
			autoplayAnimations.append(animationName)
	frames = spriteFramesInstance
	position = Vector2(sprite.x, sprite.y)
	centered = false
	play('base')

func _physics_process(delta):
	if hasAutoplay and not isPlaying and animation == 'base':
		autoplayTimer += delta
	if(autoplayTimer >= autoplayLimit and not isPlaying and animation == 'base' and autoplayAnimations.size() > 0):
		isPlaying = true
		play(autoplayAnimations[0])
		autoplayAnimations.push_back(autoplayAnimations.pop_front())

func end_animation():
	if queuedAnimations.size() > 0:
		play(queuedAnimations[0])
		queuedAnimations.pop_front()
	elif autoplayAnimations.has(animation):
		end_animation_autoplay()
#	elif animation == 'speakToBase' and !isQueuing:
	elif animation == 'speakToBase':
		play('base')

func play_after_autoplay(name):
	if name != 'base':
		queuedAnimations.append(name)

func end_animation_autoplay():
	if queuedAnimations.size() > 0:
		play(queuedAnimations[0])
		queuedAnimations.pop_front()
		randomize()
		autoplayLimit = randi() % int(autoplayDelay) + 1
		autoplayTimer = 0
		isPlaying = false
	elif not animation == 'base':
		play('base')
		randomize()
		autoplayLimit = randi() % int(autoplayDelay) + 1
		autoplayTimer = 0
		isPlaying = false

func set_queueing(mode):
	isQueuing = mode

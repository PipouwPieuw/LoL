extends AnimatedSprite

var autoplay = false
var isPlaying = false
var autoplayDelay = 0
var autoplayLimit = 0
var autoplayTimer = 0
var autoplayAnimations = []
var _err

func _ready():
	add_to_group('sceneSprite')
	if autoplayDelay != 0:
		autoplayLimit = randi() % int(autoplayDelay) + 1

func init(sprite, layout, name):
	var spriteFramesInstance = SpriteFrames.new()
	var spriteSize = Vector2(sprite.width, sprite.height)
	var animationSpriteSheet : Texture = load('assets/sprites/animations/' + layout + '/' +  name + '.png')
	if sprite.has('autoplayDelay'):
		autoplay = true
		autoplayDelay = sprite.autoplayDelay
		_err = self.connect('animation_finished', self, 'end_animation_autoplay')
	else:
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
	if autoplay and not isPlaying and animation == 'base':
		autoplayTimer += delta
	if(autoplayTimer >= autoplayLimit and not isPlaying and animation == 'base' and autoplayAnimations.size() > 0):
		isPlaying = true
		play(autoplayAnimations[0])
		autoplayAnimations.push_back(autoplayAnimations.pop_front())

func end_animation():
	if animation == 'speakToBase':
		play('base')

func end_animation_autoplay():
	if not animation == 'base':
		play('base')
		randomize()
		autoplayLimit = randi() % int(autoplayDelay) + 1
		autoplayTimer = 0
		isPlaying = false

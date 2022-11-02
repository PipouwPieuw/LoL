extends Node2D

var currentData = {}
var currentLayout = ''
var currentScene = ''

onready var scene = preload("res://layout/Scene.tscn")

func _ready():
	add_to_group('scenecontainer')

func load_scenes(layoutName):
	var file = File.new()
	file.open('res://data/scenes.json', File.READ)
	var fileContent = parse_json(file.get_as_text())
	file.close()
	if fileContent.has(layoutName):
		currentData = fileContent[layoutName]
		currentLayout = layoutName

func display_scene(sceneName):
	currentScene = sceneName
	var sceneInstance = scene.instance()
	sceneInstance.find_node('Background').texture = load('assets/sprites/scenes/' + currentLayout + '/' +  currentScene + '.png')
	for sprite in currentData[currentScene].sprites:
		sceneInstance.add_child(add_sprite(sprite))
	add_child(sceneInstance)

func add_sprite(spriteName):
	var sprite = currentData[currentScene].sprites[spriteName]
	var animatedSpriteInstance = AnimatedSprite.new()
	var spriteFramesInstance = SpriteFrames.new()
	var spriteSize = Vector2(sprite.width, sprite.height)
	var animationSpriteSheet : Texture = load('assets/sprites/animations/' + currentLayout + '/' +  currentScene + '.png')
	for animationName in sprite.animations:
		var animation = sprite.animations[animationName]
		var counter = 0
		for x in animation.frames:
			var frame = AtlasTexture.new()
			frame.atlas = animationSpriteSheet
			frame.region = Rect2(Vector2(x, 0) * spriteSize, spriteSize)
			spriteFramesInstance.add_frame(animationName, frame, counter)
			counter += 1
#		spriteFramesInstance.set_animation_loop("default", true)
	animatedSpriteInstance.frames = spriteFramesInstance
#	animatedSpriteInstance.speed_scale = 3
	animatedSpriteInstance.position = Vector2(sprite.x, sprite.y)
	animatedSpriteInstance.centered = false
	animatedSpriteInstance.playing = true
	return animatedSpriteInstance


func exit_scene():
	pass

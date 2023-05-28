extends Node2D

var currentData = {}
var currentLayout = ''
var currentScene = ''
var currentSceneInstance
var _err

onready var scene = preload("res://layout/Scene.tscn")
onready var triggerZone = preload("res://boxes/triggerZone.tscn")
onready var sceneBox = $Scene
onready var exitScene = $ExitScene

func _ready():
	add_to_group('scenecontainer')
	_err = exitScene.connect("input_event", self, "exit_scene")

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
	# Animation sprites
	for sprite in currentData[currentScene].sprites:
		sceneInstance.add_child(add_sprite(sprite))
	# Trigger areas
	for zone in currentData[currentScene].triggerZones:
		sceneInstance.add_child(add_zone(currentData[currentScene].triggerZones[zone]))
	currentSceneInstance = sceneInstance
	sceneBox.add_child(sceneInstance)
	disable_inputs(true)
	get_tree().call_group('dialogbox', 'expand_box', 'scene')
	yield(get_tree().create_timer(.8), "timeout")
	disable_inputs(false)

func add_sprite(spriteName):
	var sprite = currentData[currentScene].sprites[spriteName]
	var animatedSpriteInstance = AnimatedSprite.new()
	var spriteFramesInstance = SpriteFrames.new()
	var spriteSize = Vector2(sprite.width, sprite.height)
	var animationSpriteSheet : Texture = load('assets/sprites/animations/' + currentLayout + '/' +  currentScene + '.png')
	for animationName in sprite.animations:
		var animation = sprite.animations[animationName]
		var counter = 0
		if !spriteFramesInstance.has_animation(animationName):
			spriteFramesInstance.add_animation(animationName)
		for x in animation.frames:
			var frame = AtlasTexture.new()
			frame.atlas = animationSpriteSheet
			frame.region = Rect2(Vector2(x, 0) * spriteSize, spriteSize)
			spriteFramesInstance.add_frame(animationName, frame, counter)
			counter += 1
#		spriteFramesInstance.set_animation_loop("default", true)
	animatedSpriteInstance.frames = spriteFramesInstance
#	animatedSpriteInstance.speed_scale = sprite.speed
	animatedSpriteInstance.position = Vector2(sprite.x, sprite.y)
	animatedSpriteInstance.centered = false
	animatedSpriteInstance.playing = true
	return animatedSpriteInstance

func add_zone(zone):
	var zoneArea = triggerZone.instance()
	var zoneShape = zoneArea.find_node('zoneShape')
	zoneArea.zoneData = zone
	zoneArea.position.x = zone.x + zone.width / 2
	zoneArea.position.y = zone.y + zone.height / 2
	# Build shape
	var shape = RectangleShape2D.new()
	shape.set_extents(Vector2(zone.width / 2, zone.height / 2))
	zoneShape.set_shape(shape)
	zoneArea.add_to_group('scenezones')
	# Return zone
	return(zoneArea)

func exit_scene(_target, event, _shape):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		disable_inputs(true)
		get_tree().call_group('dialogbox', 'unexpand_box')
		yield(get_tree().create_timer(.8), "timeout")
		get_tree().call_group('viewport', 'remove_scene')
		sceneBox.remove_child(currentSceneInstance)
		for sprite in currentSceneInstance.get_children():
			sprite.queue_free()
		currentSceneInstance.queue_free()

func disable_inputs(mode):
	exitScene.set_disabled(mode)
	get_tree().call_group('scenezones', 'set_disabled', mode)

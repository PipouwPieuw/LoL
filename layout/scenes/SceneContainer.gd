extends Node2D

var currentData = {}
var currentLayout = ''
var currentScene = ''
var currentSceneInstance
var actionsQueue = []
var isExiting = false
var _err

onready var scene = preload('res://layout/scenes/Scene.tscn')
onready var sceneSprite = preload('res://layout/scenes/SceneSprite.tscn')
onready var triggerZone = preload('res://boxes/triggerZone.tscn')
onready var sceneBox = $Scene
onready var exitScene = $ExitScene

func _ready():
	add_to_group('scenecontainer')
	_err = exitScene.connect('input_event', self, 'exit_scene')

func load_scenes(levelName):
	currentLayout = levelName
	get_tree().call_group('data', 'get_scene_data', levelName)
#	var file = File.new()
#	file.open('res://data/scenes.json', File.READ)
#	var fileContent = parse_json(file.get_as_text())
#	file.close()
#	if fileContent.has(layoutName):
#		currentData = fileContent[layoutName]
#		currentLayout = layoutName
#	get_tree().call_group('controller', 'save_scene_data', layoutName, currentData)
		
#func load_scenes_from_data(layoutName, data):
#	currentData = data
#	currentLayout = layoutName

func load_scenes_callback(sceneData):
	currentData = sceneData

func display_scene(sceneName):
	get_tree().call_group('controller', 'set_scene_displayed', true)
	currentScene = sceneName
	# Update viewport on scene autodisplay
	if currentData[currentScene].has('autoDisplay') and currentData[currentScene].autoDisplay:
		get_tree().call_group('controller', 'send_walls_status', 'default', true)
		get_tree().call_group('controller', 'clear_inputs')
	# Hide exit button 
	if currentData[currentScene].has('exitButton') and !currentData[currentScene].exitButton:
		exitScene.visible = false
	else:
		exitScene.visible = true
	# Scene display
	var sceneInstance = scene.instance()
	sceneInstance.find_node('Background').texture = load('assets/sprites/scenes/' + currentLayout + '/' +  currentScene + '.png')
	# Animation sprites
	for sprite in currentData[currentScene].sprites:
		sceneInstance.add_child(add_sprite(sprite))
	# Trigger areas
	for zone in currentData[currentScene].triggerZones:
		sceneInstance.add_child(add_zone(currentData[currentScene].triggerZones[zone]))
	currentSceneInstance = sceneInstance
	sceneInstance.add_to_group('scene')
	sceneBox.add_child(sceneInstance)
	if currentData[currentScene].has('music'):
		get_tree().call_group('audiostream', 'play_music', currentData[currentScene].music)
	disable_inputs(true)
	if currentData[currentScene].has('expandDialogBox') and currentData[currentScene].expandDialogBox:
		get_tree().call_group('boxtext', 'remove_from_queue')
		get_tree().call_group('dialogbox', 'expand_box', 'scene')
		yield(get_tree().create_timer(.8), 'timeout')
	if currentData[currentScene].has('onFirstArrival') and currentData[currentScene].has('isFirstVisit') and currentData[currentScene].isFirstVisit:
		currentData[currentScene].isFirstVisit = false
		actionsQueue = currentData[currentScene].onFirstArrival.duplicate(true)
		process_actions_queue()
	elif currentData[currentScene].has('onArrival'):
		actionsQueue = currentData[currentScene].onArrival.duplicate(true)
		process_actions_queue()
	elif currentData[currentScene].has('canMove') and currentData[currentScene].canMove:
		get_tree().call_group('triggerzones', 'set_disabled', false)
		disable_inputs_walkable(false)
	else:
		disable_inputs(false)

func add_sprite(spriteName):
	var sprite = currentData[currentScene].sprites[spriteName]
	var animatedSpriteInstance = sceneSprite.instance()
	animatedSpriteInstance.init(sprite, currentLayout, spriteName)
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
	# Build sprite
	if zone.has('sprite'):
		var spriteInstance = Sprite.new()
		spriteInstance.texture = load('assets/sprites/scenes/' + currentLayout + '/' +  zone.sprite + '.png')
		if zone.has('quantityMax'):
			spriteInstance.hframes = zone.quantityMax
			if zone.quantityCurrent == zone.quantityMax:
				spriteInstance.visible = false
			else:
				spriteInstance.frame = zone.quantityCurrent
			spriteInstance.add_to_group(zone.sprite + 'sprite')
		zoneArea.add_child(spriteInstance)
		zoneArea.move_child(spriteInstance, 0)
	# Return zone
	return(zoneArea)

func process_actions_queue():
	get_tree().call_group('boxtext', 'remove_from_queue')
	get_tree().call_group('sceneSprite', 'set_queueing', true)
	play_animation('base')
	if actionsQueue.size() > 0:
		var currentAction = actionsQueue.pop_front()
		var actionType = currentAction[0]
		var actionArg = currentAction[1]
		if actionType == 'displaySceneText':
			display_text(actionArg, true)
		elif actionType == 'playAnimation':
			play_animation(actionArg, true)
	else:
		get_tree().call_group('sceneSprite', 'set_queueing', false)
		if isExiting:
			close_scene()
		else:
			disable_inputs(false)

func display_text(text, arrivalCallback = false, disableInputs = false):
	if disableInputs:
		disable_inputs(true)
	get_tree().call_group('dialogbox', 'displayText', text, false, 'scene', arrivalCallback)
	play_animation('speak', false)

func play_animation(animationName, autoKill = false):
	for sprite in get_tree().get_nodes_in_group('sceneSprite'):
		if sprite.frames.has_animation(animationName) and sprite.animation != animationName:
			if !sprite.isPlaying:
				if autoKill:
					_err = sprite.connect('animation_finished', self, 'end_animation', [sprite])
				sprite.play(animationName)
			elif sprite.autoplayAnimations.has(sprite.animation):
				sprite.play_after_autoplay(animationName)

func end_animation(sprite):
	_err = sprite.disconnect('animation_finished', self, 'end_animation')
	if sprite.frames.has_animation('base'):
		sprite.play('base')
	process_actions_queue()

func stop_speaking():
	for sprite in get_tree().get_nodes_in_group('sceneSprite'):
		if sprite.animation == 'speak':
			if sprite.frames.has_animation('speakToBase'):
				sprite.play('speakToBase')
			else:
				sprite.play('base')

func exit_scene(_target, event, _shape):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		disable_inputs(true)
		if currentData[currentScene].has('onExit'):
			actionsQueue = currentData[currentScene].onExit.duplicate(true)
			isExiting = true
			process_actions_queue()
		else:
			close_scene()

func close_scene(callback = '', callbackArgs = [], screenTransition = true):
	if currentData[currentScene].has('expandDialogBox') and currentData[currentScene].expandDialogBox:
		get_tree().call_group('dialogbox', 'unexpand_box')
		yield(get_tree().create_timer(.8), "timeout")
	if currentData[currentScene].has('exitDirection'):
		get_tree().call_group('controller', 'set_direction', currentData[currentScene].exitDirection)
	if screenTransition:
		get_tree().call_group('screentransition', 'transition', 'viewport', {})
		yield(get_tree().create_timer(.25), "timeout")
	sceneBox.remove_child(currentSceneInstance)
	for sprite in currentSceneInstance.get_children():
		sprite.queue_free()
	currentSceneInstance.remove_from_group('scene')
	currentSceneInstance.queue_free()
	if currentData[currentScene].has('canMove') and currentData[currentScene].canMove:
		disable_inputs_walkable(true)
	if currentData[currentScene].has('music'):
		get_tree().call_group('controller', 'play_level_music')
	get_tree().call_group('purse', 'set_active', false)
	get_tree().call_group('inventory', 'set_active', true)
	isExiting = false
	get_tree().call_group('controller', 'set_scene_displayed', false)
	if callback != '':
		callv(callback, callbackArgs)

func disable_inputs(mode):
	exitScene.set_disabled(mode)
	get_tree().call_group('scenezones', 'set_disabled', mode)
	get_tree().call_group('inventory', 'set_active', !mode)
	get_tree().call_group('atlas', 'set_active', !mode)
	get_tree().call_group('purse', 'set_active', mode)

func disable_inputs_walkable(mode):
	get_tree().call_group('atlas', 'set_active', !mode)
	get_tree().call_group('party', 'toggle_triggers', mode)
	get_tree().call_group('inventory', 'set_active', !mode)
	get_tree().call_group('purse', 'set_active', mode)
	exitScene.set_disabled(mode)

func update_sprites():
	for zone in get_tree().get_nodes_in_group('scenezones'):
		if zone.zoneData.has('quantityCurrent'):
			var sprite = get_tree().get_nodes_in_group(zone.zoneData.sprite + 'sprite')[0]
			if zone.zoneData.quantityCurrent < zone.zoneData.quantityMax:
				sprite.visible = true
				sprite.frame = zone.zoneData.quantityCurrent
			else:
				sprite.visible = false

func move_forward():
	if currentData[currentScene].has('onWalkForward'):
		for event in currentData[currentScene].onWalkForward:
			call(event.actionType, event.actionId, event.actionArgs)
	else:
		get_tree().call_group('controller', 'bump_animation', 'up')

func load_level(levelName, args, callback = false):
	if !callback:
		get_tree().call_group('screentransition', 'transition', 'viewport', {}, .1)
		yield(get_tree().create_timer(.25), "timeout")
		close_scene('load_level', [levelName, args, true], false)
	else:
		get_tree().call_group('controller', 'load_level', levelName, args)

extends Node2D

export(String) var initialMap

#var mainData         = {}
var currentData      = {}
var currentCell      = -1
var currentCellL     = -1
var currentCellR     = -1
var currentCellU     = -1
var currentCellUL    = -1
var currentCellUR    = -1
var currentCellUU    = -1
var currentCellUUL   = -1
var currentCellUULL  = -1
var currentCellUUR   = -1
var currentCellUURR  = -1
var currentCellUUU   = -1
var currentCellUUUR  = -1
var currentCellUUUL  = -1
var mapWidth         = 0
var directions       = ['U', 'R', 'D', 'L']
var animatedDoors    = []
var inputQueue       = []
var inputProcessing  = false
var currentShop      = {}
var initialCoins     = 41
var coins            = 0
var mainCharId       = '003'
var sceneDisplayed   = false

func _ready():
	add_to_group('controller')
	get_tree().call_group('partymain', 'set_main_member_id', mainCharId)
	get_tree().call_group('purse', 'set_amount', initialCoins, false)
	var levelToLoad = 'gladstone'
	if initialMap != '':
		levelToLoad = initialMap
	load_level(levelToLoad)
	
func _physics_process(_delta):
	if !inputProcessing and inputQueue.size() > 0:
		inputProcessing = true
		var processedInput = inputQueue.pop_front()
		get_tree().call_group('hudarrows', 'darken', processedInput)
		if sceneDisplayed:
			if processedInput == 'up':
				get_tree().call_group('scenecontainer', 'move_forward')
				return
			else:
				get_tree().call_group('scenecontainer', 'close_scene')
		if 'turn' in processedInput:
			change_direction(processedInput)
		else:
			check_move(processedInput)
	
func load_level(levelName, args = {}):
	# Load level date
	get_tree().call_group('data', 'get_level_data', levelName, args)
	# Save current level data on level change
#	save_data()
	# Load level data or blank level
#	if mainData.has('levels') and mainData['levels'].has(levelName):
#		currentData = mainData['levels'][levelName]
#	else:
#	var file = File.new()
#	file.open('res://data/levels/' + levelName + '.json', File.READ)
#	currentData = parse_json(file.get_as_text())
#	file.close()
#	mainData[levelName] = currentData.duplicate(true)
	# Load scenes data or blank scenes
#	if mainData.has('scenes') and mainData['scenes'].has(levelName):
#		get_tree().call_group('scenecontainer', 'load_scenes_from_data', levelName, mainData['scenes'][levelName])
#	else:

func load_level_callback(levelData, args = {}):
	currentData = levelData
	var levelName = currentData.id
	get_tree().call_group('scenecontainer', 'load_scenes', levelName)
	mapWidth = int(currentData.width)
	get_tree().call_group('viewport', 'update_layout', currentData.layout, currentData.spriteSheetFrames)
	play_level_music()
	var startIndex = currentData.start_index
	if args.has('targetCell'):
		startIndex = args.targetCell
	set_cells(int(startIndex))
	if args.has('direction'):
		while(directions[0] != args.direction):
			change_direction('turnright')
	draw_map()
	send_walls_status('up')
	get_tree().call_group('inputs', 'set_move', true)

func play_level_music():
	if currentData.music != '':
		get_tree().call_group('audiostream', 'play_music', currentData.music)

func set_cells(index):
	currentCell = index
	# Facing UP
	if(directions[0] == 'U'):
		currentCellL     = index - 1
		currentCellR     = index + 1
		currentCellU     = index - mapWidth
		currentCellUL    = index - mapWidth - 1
		currentCellUR    = index - mapWidth + 1
		currentCellUU    = index - mapWidth * 2
		currentCellUUL   = index - mapWidth * 2 - 1
		currentCellUULL  = index - mapWidth * 2 - 2
		currentCellUUR   = index - mapWidth * 2 + 1
		currentCellUURR  = index - mapWidth * 2 + 2
		currentCellUUU   = index - mapWidth * 3
		currentCellUUUR  = index - mapWidth * 3 + 1
		currentCellUUUL  = index - mapWidth * 3 - 1
	# Facing RIGHT
	if(directions[0] == 'R'):
		currentCellL     = index - mapWidth
		currentCellR     = index + mapWidth
		currentCellU     = index + 1
		currentCellUL    = index - mapWidth + 1
		currentCellUR    = index + mapWidth + 1
		currentCellUU    = index + 2
		currentCellUUL   = index - mapWidth + 2
		currentCellUULL  = index - mapWidth * 2 + 2
		currentCellUUR   = index + mapWidth + 2
		currentCellUURR  = index + mapWidth * 2 + 2
		currentCellUUU   = index + 3
		currentCellUUUR  = index + mapWidth + 3
		currentCellUUUL  = index - mapWidth + 3
	# Facing DOWN
	if(directions[0] == 'D'):
		currentCellL     = index + 1
		currentCellR     = index - 1
		currentCellU     = index + mapWidth
		currentCellUL    = index + mapWidth + 1
		currentCellUR    = index + mapWidth - 1
		currentCellUU    = index + mapWidth * 2
		currentCellUUL   = index + mapWidth * 2 + 1
		currentCellUULL  = index + mapWidth * 2 + 2
		currentCellUUR   = index + mapWidth * 2 - 1
		currentCellUURR  = index + mapWidth * 2 - 2
		currentCellUUU   = index + mapWidth * 3
		currentCellUUUR  = index + mapWidth * 3 + 1
		currentCellUUUL  = index + mapWidth * 3 - 1
	# Facing LEFT
	if(directions[0] == 'L'):
		currentCellL     = index + mapWidth
		currentCellR     = index - mapWidth
		currentCellU     = index - 1
		currentCellUL    = index + mapWidth - 1
		currentCellUR    = index - mapWidth - 1
		currentCellUU    = index - 2
		currentCellUUL   = index + mapWidth - 2
		currentCellUULL  = index + mapWidth * 2 - 2
		currentCellUUR   = index - mapWidth - 2
		currentCellUURR  = index - mapWidth * 2 - 2
		currentCellUUU   = index - 3
		currentCellUUUR  = index - mapWidth - 3
		currentCellUUUL  = index + mapWidth - 3

func draw_map():
	get_tree().call_group('map', 'draw_map', currentData)

func send_walls_status(moveDirection, staticMode = false):
	if moveDirection == 'default':
		moveDirection = directions[0]
	var cells = [
		currentCell,
		currentCellL,
		currentCellR,
		currentCellU,
		currentCellUL,
		currentCellUR,
		currentCellUU,
		currentCellUUL,
		currentCellUULL,
		currentCellUUR,
		currentCellUURR,
		currentCellUUU,
		currentCellUUUR,
		currentCellUUUL
	]
	var cellNames = [
		'currentCell',
		'currentCellL',
		'currentCellR',
		'currentCellU',
		'currentCellUL',
		'currentCellUR',
		'currentCellUU',
		'currentCellUUL',
		'currentCellUULL',
		'currentCellUUR',
		'currentCellUURR',
		'currentCellUUU',
		'currentCellUUUR',
		'currentCellUUUL'
	]
	var wallsStatus = {"cellIndex": currentCell}
	var i = 0
	# Wall sprites
	for cellIndex in cells:
		var cell = currentData.grid[cellIndex]
		var cellName = cellNames[i]
		wallsStatus[cellName] = {}
		if !['E', 'X'].find(cell.type) > -1:
			if directions[0] == 'U':
				wallsStatus[cellName].wallFrontSpriteIndex = cell.wallAttr.wallFront.spriteIndex
				wallsStatus[cellName].wallLeftSpriteIndex = cell.wallAttr.wallLeft.spriteIndex
				wallsStatus[cellName].wallRightSpriteIndex = cell.wallAttr.wallRight.spriteIndex
			elif directions[0] == 'R':
				wallsStatus[cellName].wallFrontSpriteIndex = cell.wallAttr.wallRight.spriteIndex
				wallsStatus[cellName].wallLeftSpriteIndex = cell.wallAttr.wallFront.spriteIndex
				wallsStatus[cellName].wallRightSpriteIndex = cell.wallAttr.wallBack.spriteIndex
			elif directions[0] == 'D':
				wallsStatus[cellName].wallFrontSpriteIndex = cell.wallAttr.wallBack.spriteIndex
				wallsStatus[cellName].wallLeftSpriteIndex = cell.wallAttr.wallRight.spriteIndex
				wallsStatus[cellName].wallRightSpriteIndex = cell.wallAttr.wallLeft.spriteIndex
			elif directions[0] == 'L':
				wallsStatus[cellName].wallFrontSpriteIndex = cell.wallAttr.wallLeft.spriteIndex
				wallsStatus[cellName].wallLeftSpriteIndex = cell.wallAttr.wallBack.spriteIndex
				wallsStatus[cellName].wallRightSpriteIndex = cell.wallAttr.wallFront.spriteIndex
		else:
			wallsStatus[cellName].wallFrontSpriteIndex = -1
			wallsStatus[cellName].wallLeftSpriteIndex = -1
			wallsStatus[cellName].wallRightSpriteIndex = -1
		i += 1
	# Front wall interaction zones
	if directions[0] == 'U':
		wallsStatus['currentCell'].InteractionZones = currentData.grid[currentCell].wallAttr.wallFront.interactionZones
	elif directions[0] == 'R':
		wallsStatus['currentCell'].InteractionZones = currentData.grid[currentCell].wallAttr.wallRight.interactionZones
	elif directions[0] == 'D':
		wallsStatus['currentCell'].InteractionZones = currentData.grid[currentCell].wallAttr.wallBack.interactionZones
	elif directions[0] == 'L':
		wallsStatus['currentCell'].InteractionZones = currentData.grid[currentCell].wallAttr.wallLeft.interactionZones
	# Display scene
	if !staticMode and currentData.grid[currentCell].has('onWalkOn'):
		for event in currentData.grid[currentCell].onWalkOn:
			if event.has('directionTrigger') and event.directionTrigger.has(directions[0]):
				if moveDirection == 'up':
					get_tree().call_group('viewport', 'start_move', moveDirection, wallsStatus, false)
				call(event.actionType, event)
				return
	# Else proceed to move
	if !staticMode:
		get_tree().call_group('viewport', 'start_move', moveDirection, wallsStatus)
	else:
		get_tree().call_group('viewport', 'update_viewport', wallsStatus)

func queue_input(input):
	inputQueue.append(input)

func check_move(moveDirection):
	var currentDir = directions[0]
	# Check if moving to wall with special trigger
	if moveDirection == 'up':
		var dirs = ['U', 'R','D', 'L']
		var walls = ['wallFront', 'wallRight','wallBack', 'wallLeft']
		var targetWall = walls[dirs.find(currentDir)]
		if currentData.grid[currentCell].wallAttr[targetWall].has('onWalkTowards'):
			for event in currentData.grid[currentCell].wallAttr[targetWall].onWalkTowards:
				call(event.eventType, event, null)
			return
	# Prepare move
	var newCell = int(currentCell)
	# Move North
	if(moveDirection == 'up' and currentDir == 'U'
	or moveDirection == 'left' and currentDir == 'R'
	or moveDirection == 'down' and currentDir == 'D'
	or moveDirection == 'right' and currentDir == 'L'):
		newCell -= mapWidth
	# Move South
	if(moveDirection == 'up' and currentDir == 'D'
	or moveDirection == 'left' and currentDir == 'L'
	or moveDirection == 'down' and currentDir == 'U'
	or moveDirection == 'right' and currentDir == 'R'):
		newCell += mapWidth
	# Move East
	if(moveDirection == 'up' and currentDir == 'R'
	or moveDirection == 'left' and currentDir == 'D'
	or moveDirection == 'down' and currentDir == 'L'
	or moveDirection == 'right' and currentDir == 'U'):
		newCell += 1
	# Move West
	if(moveDirection == 'up' and currentDir == 'L'
	or moveDirection == 'left' and currentDir == 'U'
	or moveDirection == 'down' and currentDir == 'R'
	or moveDirection == 'right' and currentDir == 'D'):
		newCell -= 1
	var target = currentData.grid[newCell]
	# Check if target cell is walkable or is opened door
	if target.walkable:
		set_cells(newCell)
		get_tree().call_group('map', 'update_position', currentCell)
		send_walls_status(moveDirection)
	else:
		# Bump animation if moving forward to obstacle
		bump_animation(moveDirection)
		

func bump_animation(dir):
	get_tree().call_group('audiostream', 'play_sound', 'hud', 'bump')
	get_tree().call_group('dialogbox', 'displayText', 'You can\'t go that way!', false, 'error')
	if dir == 'up':
		get_tree().call_group('viewport', 'bump_forward')
	yield(get_tree(),"idle_frame")
	move_ended()

func change_direction(direction):
	if direction == 'turnright':
		directions.push_back (directions.pop_front())
	elif direction == 'turnleft':
		directions.push_front(directions.pop_back())
	set_cells(currentCell)
	get_tree().call_group('map', 'update_direction', directions[0])
	send_walls_status(direction)

func move_ended():
	inputProcessing = false

func clear_inputs():
	inputQueue = []
	inputProcessing = false

func update_data(data):
	currentData = data

func replace_wall(wall, index):
	currentData.grid[currentCell].wallAttr[wall].spriteIndex = index
	send_walls_status(directions[0], true)

func toggleDoor(doorIndex, _triggerZone):
	if animatedDoors.has(doorIndex):
		return
#	animatedDoors.append(doorIndex)
	var doorCell = currentData.grid[doorIndex]
	var doorFramesOpen = doorCell.doorAttr.openAnimation.duplicate(true)
	var doorFramesClose = doorCell.doorAttr.closeAnimation.duplicate(true)
	var frames = doorFramesClose.duplicate(true) if doorCell.doorAttr.isOpened else doorFramesOpen.duplicate(true)
	open_close_door(doorCell, frames)

func displayText(args, triggerZone = null):
	var text = args[0]
	var expand = args[1]
	get_tree().call_group('dialogbox', 'displayText', text, expand)
	if triggerZone != null:
		triggerZone.updateText()

func displayShop(args, _triggerZone):
	if args.quantityCurrent <= 0:
		if args.has('emptyText'):
			get_tree().call_group('scenecontainer', 'play_animation', 'speak')
			get_tree().call_group('dialogbox', 'displayText', args.emptyText, false, 'scene')
		return
	var text = args.text
	currentShop = args
	get_tree().call_group('dialogbox', 'display_shop', text)
	get_tree().call_group('scenecontainer', 'disable_inputs', true)
	get_tree().call_group('scenecontainer', 'play_animation', 'speak')

func buy_tem():
	var item = currentShop.itemId
	var price = currentShop.price
	if price <= coins:
		var diff = coins - price
		currentShop.quantityCurrent -= 1
		get_tree().call_group('inventory', 'add_item', item, true)
		get_tree().call_group('purse', 'set_amount', diff)
		get_tree().call_group('scenecontainer', 'update_sprites')
		get_tree().call_group('scenecontainer', 'disable_inputs', false)
	else:
		var text = 'Sorry, I don\'t have enough money.' 
		get_tree().call_group('dialogbox', 'displayTextWithPortrait', text, mainCharId, true)
	currentShop = {}

func discard_shop():
	currentShop = {}
	get_tree().call_group('scenecontainer', 'disable_inputs', false)

func giveItem(args, _triggerZone):
	var inventory = get_tree().get_nodes_in_group('inventory')[0]
	var effect = ''
	for action in args.giveItemActions:
		if args.giveItemActions[action].effect == 'displaySceneText':
			effect = 'display_text'
		if effect == '':
			return
		if  inventory.grabbedItem != null:
			if args.giveItemActions[action].has('validItems') and args.giveItemActions[action].validItems.find(inventory.grabbedItem) > -1:
				get_tree().call_group('scenecontainer', effect, args.giveItemActions[action].arg, false, true)
				return
			elif args.giveItemActions[action].has('excludedItems') and not args.giveItemActions[action].excludedItems.find(inventory.grabbedItem) > -1:
				get_tree().call_group('scenecontainer', effect, args.giveItemActions[action].arg, false, true)
				return
		elif not args.giveItemActions[action].has('validItems') and not args.giveItemActions[action].has('excludedItems'):
			get_tree().call_group('scenecontainer', effect, args.giveItemActions[action].arg, false, true)
			return

func set_coins(val):
	coins = val

func set_scene_displayed(val):
	sceneDisplayed = val

func keyhole(args, triggerZone):
	var activeItem = get_tree().get_nodes_in_group('inventory')[0].get_active_item()
	# No active item
	if activeItem.id == null:
		get_tree().call_group('dialogbox', 'displayText', args.text[0])
		triggerZone.updateText()
	elif args.unlocked:
		get_tree().call_group('dialogbox', 'displayText', args.unlockedText)
	else:
		# Incorrect item
		if args.acceptedItems.find(activeItem.id) == -1:
			get_tree().call_group('audiostream', 'play_sound', 'layout', 'keylockfail')
			get_tree().call_group('dialogbox', 'displayText', args.invalidText)
		# Correct item
		else:
			# Activate trigger
			get_tree().call_group('audiostream', 'play_sound', 'layout', 'keylocksuccess')
			get_tree().call_group('inventory', 'discard_active_item')
			triggerZone.zoneData.unlocked = true
			# Update door
			var targetCell = currentData.grid[args.targetCell]
			targetCell.doorAttr.triggersActivated += 1
			# Open door if all triggers have been activated
			if targetCell.doorAttr.triggersActivated == targetCell.doorAttr.triggersAmount:
				var frames = targetCell.doorAttr.openAnimation.duplicate(true)
				open_close_door(targetCell, frames)

func open_close_door(cell, frames):
	animatedDoors.append(cell.index)
	frames.invert()
	cell.doorAttr.isOpened = !cell.doorAttr.isOpened
	var animSound
	if cell.doorAttr.isOpened:
		animSound = 'doorstepopen'
	else:
		cell.walkable = false
		animSound = 'doorstepclose'
	while frames.size() > 0:
		var frame = frames.pop_back()
		yield(get_tree().create_timer(.3), "timeout")
		if frames.size() == 0 and !cell.doorAttr.isOpened:
			get_tree().call_group('audiostream', 'play_sound', 'layout', 'doorstepcloseend')
		else:
			get_tree().call_group('audiostream', 'play_sound', 'layout', animSound)
		# Update connected cells sprites
		if cell.doorAttr.connectedCellFront > -1:
			currentData.grid[cell.doorAttr.connectedCellFront].wallAttr.wallBack.spriteIndex = frame
		if cell.doorAttr.connectedCellBack > -1:
			currentData.grid[cell.doorAttr.connectedCellBack].wallAttr.wallFront.spriteIndex = frame
		if cell.doorAttr.connectedCellRight > -1:
			currentData.grid[cell.doorAttr.connectedCellRight].wallAttr.wallLeft.spriteIndex = frame
		if cell.doorAttr.connectedCellLeft > -1:
			currentData.grid[cell.doorAttr.connectedCellLeft].wallAttr.wallRight.spriteIndex = frame
		set_cells(currentCell)
		send_walls_status(directions[0], true)
	if cell.doorAttr.isOpened:
		cell.walkable = true
	animatedDoors.remove(animatedDoors.find(cell.index))

func playAnimation(event, _triggerZone):
	get_tree().call_group('viewport', 'play_animation', event.animation)

func transition_to_scene(args):
	get_tree().call_group('screentransition', 'transition', args.actionId, {})

func toggleAtlas(args, triggerZone):
	get_tree().call_group('atlas', 'display_atlas', args)
	triggerZone.zoneData.used = true

func process_escape_action():
	if get_tree().get_nodes_in_group('chardetailsactive').size() > 0:
		get_tree().call_group('chardetailsactive', 'close_details')
	else:
		get_tree().quit()

func process_accept_action():
	pass
#	if get_tree().get_nodes_in_group('boxtext').size() > 0:
#		get_tree().call_group('boxtext', 'display_next_lines')

#func save_data():
#	if !mainData.has('levels'):
#		mainData['levels'] = {}
#	if !currentData.empty():
#		var levelId = currentData.id
#		mainData['levels'][levelId] = currentData
#
#func save_scene_data(id, data):
#	if !mainData.has('scenes'):
#		mainData['scenes'] = {}
#	mainData['scenes'][id] = data

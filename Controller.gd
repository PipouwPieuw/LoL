extends Node2D

var currentData     = {}
var currentCell     = -1
var currentCellL    = -1
var currentCellR    = -1
var currentCellU    = -1
var currentCellUL   = -1
var currentCellUR   = -1
var currentCellUU   = -1
var currentCellUUL  = -1
var currentCellUULL = -1
var currentCellUUR  = -1
var currentCellUURR = -1
var currentCellUUU  = -1
var mapWidth        = 0
var directions      = ['U', 'R', 'D', 'L']
# Doors
var animatedDoors   = []

func _ready():
	add_to_group('controller')
	load_level()
	
func load_level():
	var file = File.new()
	file.open('res://gladstone.json', File.READ)
	currentData = parse_json(file.get_as_text())
	file.close()
	mapWidth = int(currentData.width)
	get_tree().call_group('viewport', 'update_layout', currentData.layout, currentData.spriteSheetFrames)
	get_tree().call_group('audiostream', 'play_music', currentData.music)
	set_cells(int(currentData.start_index))
	draw_map()
	send_walls_status('up')

func set_cells(index):
	currentCell = index
	# Facing UP
	if(directions[0] == 'U'):
		currentCellL    = index - 1
		currentCellR    = index + 1
		currentCellU    = index - mapWidth
		currentCellUL   = index - mapWidth - 1
		currentCellUR   = index - mapWidth + 1
		currentCellUU   = index - mapWidth * 2
		currentCellUUL  = index - mapWidth * 2 - 1
		currentCellUULL = index - mapWidth * 2 - 2
		currentCellUUR  = index - mapWidth * 2 + 1
		currentCellUURR = index - mapWidth * 2 + 2
		currentCellUUU  = index - mapWidth * 3
	# Facing RIGHT
	if(directions[0] == 'R'):
		currentCellL    = index - mapWidth
		currentCellR    = index + mapWidth
		currentCellU    = index + 1
		currentCellUL   = index - mapWidth + 1
		currentCellUR   = index + mapWidth + 1
		currentCellUU   = index + 2
		currentCellUUL  = index - mapWidth + 2
		currentCellUULL = index - mapWidth * 2 + 2
		currentCellUUR  = index + mapWidth + 2
		currentCellUURR = index + mapWidth * 2 + 2
		currentCellUUU  = index + 3
	# Facing DOWN
	if(directions[0] == 'D'):
		currentCellL    = index + 1
		currentCellR    = index - 1
		currentCellU    = index + mapWidth
		currentCellUL   = index + mapWidth + 1
		currentCellUR   = index + mapWidth - 1
		currentCellUU   = index + mapWidth * 2
		currentCellUUL  = index + mapWidth * 2 + 1
		currentCellUULL = index + mapWidth * 2 + 2
		currentCellUUR  = index + mapWidth * 2 - 1
		currentCellUURR = index + mapWidth * 2 - 2
		currentCellUUU  = index + mapWidth * 3
	# Facing LEFT
	if(directions[0] == 'L'):
		currentCellL    = index + mapWidth
		currentCellR    = index - mapWidth
		currentCellU    = index - 1
		currentCellUL   = index + mapWidth - 1
		currentCellUR   = index - mapWidth - 1
		currentCellUU   = index - 2
		currentCellUUL  = index + mapWidth - 2
		currentCellUULL = index + mapWidth * 2 - 2
		currentCellUUR  = index - mapWidth - 2
		currentCellUURR = index - mapWidth * 2 - 2
		currentCellUUU  = index - 3

func draw_map():
	get_tree().call_group('map', 'draw_map', currentData)

func send_walls_status(moveDirection, staticMode = false):
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
		currentCellUUU
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
		'currentCellUUU'
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
	if !staticMode:
		get_tree().call_group('viewport', 'start_move', moveDirection, wallsStatus)
	else:
		get_tree().call_group('viewport', 'update_viewport', wallsStatus)

func check_move(moveDirection):
	var currentDir = directions[0]
	# Check if moving to wall with special trigger
	var dirs = ['U', 'R','D', 'L']
	var walls = ['wallFront', 'wallRight','wallBack', 'wallLeft']
	var targetWall = walls[dirs.find(currentDir)]
	if currentData.grid[currentCell].wallAttr[targetWall].has('onWalkTowards'):
		for event in currentData.grid[currentCell].wallAttr[targetWall].onWalkTowards:
			call(event.eventType, event)
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
		get_tree().call_group('viewport', 'update_ceiling_floor')
	else:
		# Bump animation if moving forward to obstacle
		if moveDirection == 'up':
			get_tree().call_group('viewport', 'bump_forward')

func change_direction(direction):
	if direction == 'turnright':
		directions.push_back (directions.pop_front())
	elif direction == 'turnleft':
		directions.push_front(directions.pop_back())	
	set_cells(currentCell)
	get_tree().call_group('map', 'update_direction', directions[0])
	send_walls_status(direction)
	get_tree().call_group('viewport', 'update_ceiling_floor')

func update_data(data):
	currentData = data

func toggleDoor(doorIndex, _triggerZone):
	if animatedDoors.has(doorIndex):
		return
#	animatedDoors.append(doorIndex)
	var doorCell = currentData.grid[doorIndex]
	var doorFramesOpen = doorCell.doorAttr.openAnimation.duplicate(true)
	var doorFramesClose = doorCell.doorAttr.closeAnimation.duplicate(true)
	var frames = doorFramesClose.duplicate(true) if doorCell.doorAttr.isOpened else doorFramesOpen.duplicate(true)
	open_close_door(doorCell, frames)

func displayText(text, triggerZone):
	get_tree().call_group('hud', 'displayText', text)
	triggerZone.updateText()

func keyhole(args, triggerZone):
	var activeItem = get_tree().get_nodes_in_group('inventory')[0].get_active_item()
	# No active item
	if activeItem.id == -1:
		get_tree().call_group('hud', 'displayText', args.text[0])
		triggerZone.updateText()
	elif args.unlocked:
		get_tree().call_group('hud', 'displayText', args.unlockedText)
	else:
		# Incorrect item
		if args.acceptedItems.find(activeItem.id) == -1:
			get_tree().call_group('audiostream', 'play_sound', 'layout', 'keylockfail')
			get_tree().call_group('hud', 'displayText', args.invalidText)
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

func process_event():
	print(1111)

func play_animation(event):
	get_tree().call_group('viewport', 'play_animation', event.animation)

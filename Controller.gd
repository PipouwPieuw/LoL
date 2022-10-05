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

func _ready():
	add_to_group('controller')
	currentData = load_level()
	mapWidth = int(currentData.width)
	get_tree().call_group('viewport', 'update_layout', currentData.layout)
	set_cells(int(currentData.start_index))
	draw_map()
	send_walls_status('up')
	
func load_level():
	var file = File.new()
	file.open('res://test_grid.json', File.READ)
	var fileContent = parse_json(file.get_as_text())
	file.close()
	return fileContent

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

func send_walls_status(moveDirection):
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
	var wallsStatus = {}
	var i = 0
	for cellIndex in cells:
		var cell = currentData.grid[cellIndex]
		var cellName = cellNames[i]
		wallsStatus[cellName] = {}
		if cell.walkable:
			if directions[0] == 'U':
				wallsStatus[cellName].wallFrontSpriteIndex = cell.wallAttr.wallFront.spriteIndex
				wallsStatus[cellName].wallLeftSpriteIndex = cell.wallAttr.wallLeft.spriteIndex
				wallsStatus[cellName].wallRightSpriteIndex = cell.wallAttr.wallRight.spriteIndex
			if directions[0] == 'R':
				wallsStatus[cellName].wallFrontSpriteIndex = cell.wallAttr.wallRight.spriteIndex
				wallsStatus[cellName].wallLeftSpriteIndex = cell.wallAttr.wallFront.spriteIndex
				wallsStatus[cellName].wallRightSpriteIndex = cell.wallAttr.wallBack.spriteIndex
			if directions[0] == 'D':
				wallsStatus[cellName].wallFrontSpriteIndex = cell.wallAttr.wallBack.spriteIndex
				wallsStatus[cellName].wallLeftSpriteIndex = cell.wallAttr.wallRight.spriteIndex
				wallsStatus[cellName].wallRightSpriteIndex = cell.wallAttr.wallLeft.spriteIndex
			if directions[0] == 'L':
				wallsStatus[cellName].wallFrontSpriteIndex = cell.wallAttr.wallLeft.spriteIndex
				wallsStatus[cellName].wallLeftSpriteIndex = cell.wallAttr.wallBack.spriteIndex
				wallsStatus[cellName].wallRightSpriteIndex = cell.wallAttr.wallFront.spriteIndex
		else:
			wallsStatus[cellName].wallFrontSpriteIndex = -1
			wallsStatus[cellName].wallLeftSpriteIndex = -1
			wallsStatus[cellName].wallRightSpriteIndex = -1
		i += 1
	get_tree().call_group('viewport', 'start_move', moveDirection, wallsStatus)

func check_move(moveDirection):
	var newCell = int(currentCell)
	var currentDir = directions[0]
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
	if target.type == 'C' or (target.type == 'D' and target.doorAttr.isOpened):
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

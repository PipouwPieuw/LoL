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
		if cell.type == 'C':
			if(directions[0] == 'U'):
				wallsStatus[cellName].wallFront = cell.attr.wallFront
				wallsStatus[cellName].wallLeft  = cell.attr.wallLeft
				wallsStatus[cellName].wallRight = cell.attr.wallRight
				if cell.attr.wallFront:
					wallsStatus[cellName].wallFrontType = cell.attr.wallFrontType.name
				if cell.attr.wallLeft:
					wallsStatus[cellName].wallLeftType = cell.attr.wallLeftType.name
				if cell.attr.wallRight:
					wallsStatus[cellName].wallRightType = cell.attr.wallRightType.name
			if(directions[0] == 'R'):
				wallsStatus[cellName].wallFront = cell.attr.wallRight
				wallsStatus[cellName].wallLeft  = cell.attr.wallFront
				wallsStatus[cellName].wallRight = cell.attr.wallBack
				if cell.attr.wallRight:
					wallsStatus[cellName].wallFrontType = cell.attr.wallRightType.name
				if cell.attr.wallFront:
					wallsStatus[cellName].wallLeftType = cell.attr.wallFrontType.name
				if cell.attr.wallBack:
					wallsStatus[cellName].wallRightType = cell.attr.wallBackType.name
			if(directions[0] == 'D'):
				wallsStatus[cellName].wallFront = cell.attr.wallBack
				wallsStatus[cellName].wallLeft  = cell.attr.wallRight
				wallsStatus[cellName].wallRight = cell.attr.wallLeft
				if cell.attr.wallBack:
					wallsStatus[cellName].wallFrontType = cell.attr.wallBackType.name
				if cell.attr.wallRight:
					wallsStatus[cellName].wallLeftType = cell.attr.wallRightType.name
				if cell.attr.wallLeft:
					wallsStatus[cellName].wallRightType = cell.attr.wallLeftType.name
			if(directions[0] == 'L'):
				wallsStatus[cellName].wallFront = cell.attr.wallLeft
				wallsStatus[cellName].wallLeft  = cell.attr.wallBack
				wallsStatus[cellName].wallRight = cell.attr.wallFront
				if cell.attr.wallLeft:
					wallsStatus[cellName].wallFrontType = cell.attr.wallLeftType.name
				if cell.attr.wallBack:
					wallsStatus[cellName].wallLeftType = cell.attr.wallBackType.name
				if cell.attr.wallFront:
					wallsStatus[cellName].wallRightType = cell.attr.wallFrontType.name
		else:
			wallsStatus[cellName].wallFront = false
			wallsStatus[cellName].wallLeft  = false
			wallsStatus[cellName].wallRight = false
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
	if(currentData.grid[newCell].type == 'C'):
		set_cells(newCell)
		get_tree().call_group('map', 'update_position', currentCell)
		send_walls_status(moveDirection)
		get_tree().call_group('viewport', 'update_ceiling_floor')
	else:
		# TODO : WALL BUMP ANIMATION
		pass

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

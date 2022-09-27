extends Node2D

var currentData = {}
var currentCell = -1
var directions = ['U', 'R', 'D', 'L']

func _ready():
	add_to_group('controller')
	currentData = load_level()
	currentCell = currentData.start_index
	draw_map()
	send_walls_status()
	
func load_level():
	var file = File.new()
	file.open('res://test_grid.json', File.READ)
	var fileContent = parse_json(file.get_as_text())
	file.close()
	return fileContent

func draw_map():
	get_tree().call_group('map', 'draw_map', currentData)

func send_walls_status():
	var wallsStatus = {
		'wallFront': currentData.grid[currentCell].attr.wallFront,
		'wallLeft': currentData.grid[currentCell].attr.wallLeft,
		'wallRight': currentData.grid[currentCell].attr.wallRight
	}
	get_tree().call_group('viewport', 'update_walls', wallsStatus)

func check_move(moveDirection):
	var newCell = int(currentCell)
	var mapWidth = int(currentData.width)
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
		currentCell = newCell
		get_tree().call_group('map', 'update_position', currentCell)
		send_walls_status()
	else:
		# TODO : WALL BUMP ANIMATION
		pass

func change_direction(direction):
	if direction == 'right':
		directions.push_back (directions.pop_front())
	elif direction == 'left':
		directions.push_front(directions.pop_back())
	get_tree().call_group('map', 'update_direction', directions[0])

func update_data(data):
	currentData = data

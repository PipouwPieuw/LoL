extends Node2D

onready var container = $Container
onready var player = $Container/Player
onready var locationLabel = $Location
onready var legend = $Legend
onready var close = $Close

onready var mapCell = preload("res://layout/MapCell.tscn")
onready var legendItemScene = preload("res://layout/LegendItem.tscn")

var safeSpace = 3
var cellSizeX = 7
var cellSizeY = 6
var currentPos = 0
var mapWidth = 0
var cells = []
var cellNodes = {}
var gridW = 0
var gridH = 0
var atlasActive = false
var _err

func _ready():
	add_to_group("map")
	container.position.x = -safeSpace * cellSizeX
	container.position.y = -safeSpace * cellSizeY
	_err = close.connect("input_event", self, "close_map")

func draw_map(data):
	locationLabel.text = data.name
	mapWidth = int(data.width)
	currentPos = int(data.start_index)
	cells = data.grid
	gridW = data.width
	gridH = data.height
	var specialCells = 0
	# Drawing map
	for cell in cells:
		if ['C', 'D', 'S'].find(cell.type) > -1:
			var cellIndex = int(cell.index)
			var cellItem = mapCell.instance()
			cellItem.data = cell
			cellItem.position = calc_position(cellIndex, mapWidth)
			if cell.type == 'S':
				var rect = cellItem.find_node('Bg')
				rect.rect_size = Vector2(cellSizeX-2, cellSizeY-2)
				rect.rect_position.x = 1
				rect.rect_position.y = 1
				rect.color = Color(cell.color)
				var legendItemInstance = legendItemScene.instance()
				legendItemInstance.find_node('Color').color = Color(cell.color)
				legendItemInstance.find_node('Label').text = cell.label
				legendItemInstance.position.y = specialCells * 8
				legend.add_child(legendItemInstance)
				specialCells += 1
				rect.visible = true
			container.add_child(cellItem)
			cellNodes[str(cellIndex)] = cellItem
	# Set current pos
	var start_index = currentPos
	player.position = calc_position(start_index, mapWidth)

func calc_position(index, width, offset = 0):
	var posX = cellSizeX * (index % width) + offset
	var posY = cellSizeY * int(index / width) + offset
	return Vector2(posX, posY)

func update_position(newPos):
	currentPos = newPos
	player.position = calc_position(currentPos, mapWidth)
	if atlasActive:
		reveal_cells()

func update_direction(direction):
	if direction == 'R' or direction == 'L':
		player.offset.y = -5
		player.rotation_degrees = 90
	if direction == 'U' or direction == 'D':
		player.offset.y = 0
		player.rotation_degrees = 0
	if direction == 'L' or direction == 'D':
		player.flip_v = true
	if direction == 'R' or direction == 'U':
		player.flip_v = false

func reveal_cells():
	# Current cell ; cell top, cell bottom, cell left, cell right
	var cellsToCheck = [currentPos, currentPos - gridW, currentPos + gridW, currentPos - 1, currentPos + 1]
	while(cellsToCheck.size() > 0):
		var currentCell = cellsToCheck.pop_back()
		if check_explored(currentCell):
			set_explored(currentCell)
	# Top left cell ; top right cell ; bottom left cell ; bottom right cell
	cellsToCheck = [currentPos - gridW - 1, currentPos - gridW + 1, currentPos + gridW - 1, currentPos + gridW + 1]
	var cellsConditions1 = [currentPos - gridW, currentPos - gridW, currentPos + gridW, currentPos + gridW]
	var cellsConditions2 = [currentPos - 1, currentPos + 1, currentPos - 1, currentPos + 1]
	while(cellsToCheck.size() > 0):
		var currentCell = cellsToCheck.pop_back()
		var currentCellCondition1 = cellsConditions1.pop_back()
		var currentCellCondition2 = cellsConditions2.pop_back()
		if check_walkable(currentCellCondition1) and check_walkable(currentCellCondition2) and check_explored(currentCell):
			set_explored(currentCell)
		elif (check_walkable(currentCellCondition1) or check_walkable(currentCellCondition2)) and check_special_cell(currentCell):
			set_explored(currentCell)		
	# Top cell +1 ; bottom cell +1 ; left cell +1 ; right cell +1
	cellsToCheck = [currentPos - gridW * 2, currentPos + gridW * 2, currentPos - 2, currentPos + 2]
	cellsConditions1 = [currentPos - gridW, currentPos + gridW, currentPos -1, currentPos + 1]
	while(cellsToCheck.size() > 0):
		var currentCell = cellsToCheck.pop_back()
		var currentCellCondition1 = cellsConditions1.pop_back()
		if (check_walkable(currentCellCondition1) or check_special_cell(currentCellCondition1)) and check_special_cell(currentCell):
			set_explored(currentCell)

func check_explored(pos):
	return (cells[pos].walkable or ['D', 'S'].has(cells[pos].type)) and !cells[pos].explored
	
func check_walkable(pos):
	return cells[pos].walkable

func check_special_cell(pos):
	return ['D', 'S'].has(cells[pos].type)

func set_explored(pos):
	cells[pos].explored = true
	cellNodes[str(pos)].set_explored()

func toggle_atlas_state(state):
	atlasActive = state

func toggle(state):
	visible = state

func close_map(_viewport, event, _shape_idx):
	if event is InputEventMouseButton  and event.button_index == BUTTON_LEFT and event.pressed:
		get_tree().call_group('inputs', 'set_move', true)
		toggle(false)
		get_tree().call_group('hud', 'toggle', true)

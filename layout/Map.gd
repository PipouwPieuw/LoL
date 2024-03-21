extends Node2D

onready var minimap = $Container/Minimap
onready var player = $Container/Minimap/Player
onready var cellsContainer = $Container/Minimap/CellsContainer
onready var locationLabel = $Location
onready var legendSpecial = $LegendSpecial
onready var legendOthers = $LegendOthers
onready var close = $Close

onready var mapCell = preload("res://layout/MapCell.tscn")
onready var legendItemScene = preload("res://layout/LegendItem.tscn")

var mapsData = {}
var mapMaxW = 217
var mapMaxH = 192
var cellSizeX = 7
var cellSizeY = 6
var safeSpace = 3
var currentPos = 0
var mapWidth = 0
var mapHeight = 0
var cells = []
var cellNodes = {}
var gridW = 0
var gridH = 0
var atlasActive = false
var legendOffset = 8
var legendTypes = {}
var addedLegends = []
var spritesPath = 'res://assets/sprites/map'
var _err

func _ready():
	add_to_group('map')
	_err = close.connect('input_event', self, 'close_map')
	legendTypes = load_legend()
	
func load_legend():
	var file = File.new()
	file.open('res://data/legend.json', File.READ)
	var fileContent = parse_json(file.get_as_text())
	file.close()
	return fileContent

func set_map_position():
	var marginX = floor(((mapMaxW / cellSizeX) - (mapWidth - safeSpace)) / 2)
	var marginY = floor(((mapMaxH / cellSizeY) - (mapHeight - safeSpace)) / 2)
	var posX = (-safeSpace * cellSizeX) + (marginX * cellSizeX)
	var posY = (-safeSpace * cellSizeY) + (marginY * cellSizeY)
	minimap.position.x = posX
	minimap.position.y = posY

func draw_map(data, args = {}):
	reset_map()
	mapWidth = int(data.width)
	mapHeight = int(data.height)
	set_map_position()
	locationLabel.text = data.name
	if args.has('targetCell'):
		currentPos = int(args.targetCell)
	else:
		currentPos = int(data.start_index)
	gridW = data.width
	gridH = data.height
	cells = data.grid
	var counter = 0
	# Drawing map
	for cell in cells:
		if ['C', 'D', 'S'].find(cell.type) > -1:
			var cellIndex = int(cell.index)
			var cellItem = mapCell.instance()
			cellItem.data = cell
			cellItem.cellSizeX = cellSizeX
			cellItem.cellSizeY = cellSizeY
			cellItem.position = calc_position(cellIndex, mapWidth)
			cellItem.bgIndex = counter
			cellsContainer.add_child(cellItem)
			cellNodes[str(cellIndex)] = cellItem
			if cell.explored:
				set_explored(cellIndex)
		if cell.type != 'X':
			counter += 1
	# Set current pos
	var start_index = currentPos
	player.position = calc_position(start_index, mapWidth)

func calc_position(index, width, offset = 0):
	var posX = cellSizeX * (index % width) + offset
	var posY = cellSizeY * int(index / width) + offset
	return Vector2(posX, posY)

func update_position(newPos = currentPos):
	currentPos = newPos
	player.position = calc_position(currentPos, mapWidth, 1)
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
	if cells[pos].type == 'S' and !cellNodes[str(pos)].explored:
		add_legend_special(cells[pos])
	if cellNodes[str(pos)].legendTypes.size() > 0:
		for type in cellNodes[str(pos)].legendTypes:
			if !addedLegends.has(type):
				add_legend_other(type)
	if cells[pos].type == 'D' and !cellNodes[str(pos)].explored and !addedLegends.has('door'):
		add_legend_other('door')
	cellNodes[str(pos)].set_explored()

func add_legend_special(cell):
	var legendItemInstance = legendItemScene.instance()
	legendItemInstance.find_node('Color').color = Color(cell.color)
	legendItemInstance.find_node('Sprite').visible = false
	legendItemInstance.find_node('Label').text = cell.label
	legendItemInstance.index = cell.legendIndex
	legendSpecial.add_child(legendItemInstance)
	sort_legend()

func add_legend_other(type):
	var legendItemInstance = legendItemScene.instance()
	legendItemInstance.find_node('Color').visible = false
	legendItemInstance.find_node('Sprite').texture = load(spritesPath + '/legend' + type + '.png')
	legendItemInstance.find_node('Label').text = legendTypes[type].label
	legendItemInstance.type = type
	legendItemInstance.index = legendTypes[type].index
	legendOthers.add_child(legendItemInstance)
	addedLegends.append(type)
	sort_legend()

func sort_legend():
	var counter = 0
	counter = sort_legend_type(legendSpecial, counter)
	counter = sort_legend_type(legendOthers, counter)

func sort_legend_type(container, counter):
	var legendItems = container.get_children()
	var indexes = []
	if legendItems.size() > 0:
		for item in legendItems:
			indexes.append(int(item.index))
		var maxIndex = indexes.max()
		var i = 0
		while i <= maxIndex:
			var currentIndex = indexes.find(i)
			if currentIndex > -1:
				legendItems[currentIndex].position.y = counter * legendOffset
				counter += 1
			i += 1
	return counter

func toggle_atlas_state(state):
	atlasActive = state

func toggle(state):
	visible = state

func close_map(_viewport, event, _shape_idx):
	if event is InputEventMouseButton  and event.button_index == BUTTON_LEFT and event.pressed:
		get_tree().call_group('inputs', 'set_move', true)
		toggle(false)
		get_tree().call_group('hud', 'toggle', true)

func reset_map():
	addedLegends = []
	for cell in cellsContainer.get_children():
		cellsContainer.remove_child(cell)
		cell.queue_free()
	for legend in legendSpecial.get_children():
		legendSpecial.remove_child(legend)
		legend.queue_free()
	for legend in legendOthers.get_children():
		legendOthers.remove_child(legend)
		legend.queue_free()
	get_tree().call_group('mapcells', 'queue_free')
	get_tree().call_group('maplegends', 'queue_free')

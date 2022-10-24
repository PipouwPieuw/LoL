extends Node2D

onready var container = $Container
onready var player = $Container/Player
onready var legend = $Legend

var safeSpace = 3
var cellSize = 5
var currentPos = 0
var mapWidth = 0
var cells = []
var legendItemScene = preload("res://layout/LegendItem.tscn")

func _ready():
	add_to_group("map")
	container.position.x = -safeSpace * cellSize
	container.position.y = -safeSpace * cellSize

func draw_map(data):
	mapWidth = int(data.width)
	currentPos = int(data.start_index)
	cells = data.grid
	var specialCells = 0
	# Drawing map
	for cell in cells:
		if ['C', 'D', 'S'].find(cell.type) > -1:
			var cellIndex = int(cell.index)
			var rect = ColorRect.new()
			rect.rect_size = Vector2(cellSize, cellSize)
			rect.rect_position = calc_position(cellIndex, mapWidth)
			if cell.type == 'D':
				rect.color = Color('BEBEBE')
			elif cell.type == 'S':
				rect.color = Color(cell.color)
				var legendItemInstance = legendItemScene.instance()
				legendItemInstance.find_node('Color').color = Color(cell.color)
				legendItemInstance.find_node('Label').text = cell.label
				legendItemInstance.position.y = specialCells * 10
				legend.add_child(legendItemInstance)
				specialCells += 1
			else:
				rect.color = Color('000000')
			container.add_child(rect)
	# Set current pos
	var start_index = currentPos
	player.position = calc_position(start_index, mapWidth)

func calc_position(index, width, offset = 0):
	var posX = cellSize * (index % width) + offset
	var posY = cellSize * int(index / width) + offset
	return Vector2(posX, posY)

func update_position(newPos):
	currentPos = newPos
	player.position = calc_position(currentPos, mapWidth)

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

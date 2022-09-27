extends Node2D

onready var container = $Container
onready var player = $Player

var cellSize = 5
var currentPos = 0
var mapWidth = 0
var mapSize = 0
var cells = []

func _ready():
	add_to_group("map")

func draw_map(data):
	mapWidth = int(data.width)
	mapSize = int(data.size)
	currentPos = int(data.start_index)
	cells = data.grid
	# Drawing map
	for cell in cells:
		if cell.type == 'C':
			var cellIndex = int(cell.index)
			var rect = ColorRect.new()
			rect.rect_size = Vector2(cellSize, cellSize)
			rect.rect_position = calc_position(cellIndex, mapWidth)
			rect.color = Color(0, 0, 0, 1)
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

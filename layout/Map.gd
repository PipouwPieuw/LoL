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
	player.rect_position = calc_position(start_index, mapWidth, 1)

func calc_position(index, width, offset = 0):
	var posX = cellSize * (index % width) + offset
	var posY = cellSize * int(index / width) + offset
	return Vector2(posX, posY)

func update_position(direction):
	var newPos = currentPos
	if direction == "up":
		newPos -= mapWidth
	elif direction == "down":
		newPos += mapWidth
	elif direction == "right":
		newPos += 1
	elif direction == "left":
		newPos -= 1
	if(cells[newPos].type == 'C'):
		currentPos = newPos
		player.rect_position = calc_position(currentPos, mapWidth, 1)

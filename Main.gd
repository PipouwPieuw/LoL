extends Node2D

var data = {}
var currentCell = -1


# Called when the node enters the scene tree for the first time.
func _ready():
	data = load_level()
	currentCell = data.start_index
	send_walls_status()
	

func load_level():
	var file = File.new()
	file.open("res://test_grid.json", File.READ)
	var data = parse_json(file.get_as_text())
	file.close()
	return data

func send_walls_status():
	var wallsStatus = {
		'wallFront': data.grid[currentCell].attr.wallFront,
		'wallLeft': data.grid[currentCell].attr.wallLeft,
		'wallRight': data.grid[currentCell].attr.wallRight
	}
	get_tree().call_group('viewport', 'update_walls', wallsStatus)

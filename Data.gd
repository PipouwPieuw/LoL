extends Node2D

var mainData = {}
var levelNames = [
	'gladstone',
	'northland_forest'
]

func _ready():
	add_to_group('data')
	load_data()

func load_data():
	mainData['levels'] = {}
	for levelName in levelNames:
		var file = File.new()
		file.open('res://data/levels/' + levelName + '.json', File.READ)
		mainData['levels'][levelName] = parse_json(file.get_as_text())
		file.close()

func get_level_data(levelName, args):
	var levelData = mainData['levels'][levelName]
	get_tree().call_group('controller', 'load_level_callback', levelData, args)

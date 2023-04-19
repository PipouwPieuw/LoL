extends Node2D

onready var characterNode = preload("res://party/character/Character.tscn")

var partyMembers = ['001', '002', '003']
var characters

func _ready():
	characters = load_characters()
	for i in partyMembers.size():
		var member = partyMembers[i]
		add_character(member, i)
		get_tree().call_group('chardetailscontainer', 'add_details', characters[member])


func load_characters():
	var file = File.new()
	file.open('res://data/characters.json', File.READ)
	var fileContent = parse_json(file.get_as_text())
	file.close()
	return fileContent;

func add_character(id, index):
	var characterInstance = characterNode.instance()
	characterInstance.data = characters[id]
	if(partyMembers.size() == 1):
		characterInstance.position.x = 84
	elif(partyMembers.size() == 2):
		characterInstance.position.x = 100 * index + 34
	elif(partyMembers.size() == 3):
		characterInstance.position.x = 75 * index + 9
	add_child(characterInstance)

extends Node2D

onready var characterNode = preload("res://party/character/Character.tscn")

var mainMember = '001'
var partyMembers = [mainMember, '006', '005']
var characters
var races

func _ready():
	add_to_group('partymain')
	characters = load_file('characters')
	races = load_file('races')
	if partyMembers.size() > 3:
		partyMembers.resize(3)
		
func set_main_member_id(id):
	mainMember = id
	partyMembers[0] = id
	build_party()

func build_party():
	for i in partyMembers.size():
		var member = partyMembers[i]
		characters[member]['equipment'] = races[characters[member]['attributes']['race']]['equipment']
		add_character(member, i)
		get_tree().call_group('chardetailscontainer', 'add_details', characters[member])

func load_file(name):
	var file = File.new()
	file.open('res://data/' + name + '.json', File.READ)
	var fileContent = parse_json(file.get_as_text())
	file.close()
	return fileContent;

func add_character(id, index):
	var characterInstance = characterNode.instance()
	characterInstance.data = characters[id]
	characterInstance.set_party_size(partyMembers.size())
	if(partyMembers.size() == 1):
		characterInstance.position.x = 84
	elif(partyMembers.size() == 2):
		characterInstance.position.x = 100 * index + 34
	elif(partyMembers.size() == 3):
		characterInstance.position.x = 75 * index + 9
	add_child(characterInstance)

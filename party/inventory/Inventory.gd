extends Node2D

const SLOTS_AMOUNT = 9
const SLOTS_SIZE = 20

var inventory = []
var slotScene = preload("res://party/inventory/InventoryItem.tscn")
var activeSlots

func _ready():
	inventory = load_inventory().slots
	build_inventory()
	update_inventory()
	
func load_inventory():
	var file = File.new()
	file.open('res://inventory.json', File.READ)
	var fileContent = parse_json(file.get_as_text())
	file.close()
	return fileContent

func build_inventory():
	for slot in SLOTS_AMOUNT:
		var slotInstance = slotScene.instance()
		slotInstance.find_node('ItemBg').flip_h = slot % 2 == 0
		slotInstance.position.x = SLOTS_SIZE * slot + slot + 1
		add_child(slotInstance)
	activeSlots = get_children()

func update_inventory():
	var i = 0
	for slot in activeSlots:
		var itemId = inventory[i]
		if itemId > -1:
			slot.find_node('ItemSprite').frame = itemId
			slot.find_node('ItemSprite').visible = true
		else:
			slot.find_node('ItemSprite').visible = false
		i += 1

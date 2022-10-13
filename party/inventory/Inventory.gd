extends Node2D

const SLOTS_AMOUNT = 9
const SLOTS_SIZE = 20

var inventory = []
var slotScene = preload("res://party/inventory/InventoryItem.tscn")
var activeSlots
var grabbedItem = -1
var _err

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
		_err = slotInstance.connect("input_event", self, "slot_clicked", [slotInstance, slot])
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

func slot_clicked(_target, event, _shape, slot, index):
	if event is InputEventMouseButton  and event.button_index == BUTTON_LEFT and event.pressed:
		if grabbedItem > -1:
			if inventory[index] > -1:
				pass
			else:
				inventory[index] = grabbedItem
				slot.find_node('ItemSprite').frame = grabbedItem
				slot.find_node('ItemSprite').visible = true
				grabbedItem = -1
				get_tree().call_group('cursor', 'hide_sprite')
		else:
			if inventory[index] > -1:
				grabbedItem = inventory[index]
				inventory[index] = -1
				slot.find_node('ItemSprite').visible = false
				get_tree().call_group('cursor', 'show_sprite', grabbedItem)
			else:
				pass

func grab_item():
	pass

func put_item():
	pass

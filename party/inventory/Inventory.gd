extends Node2D

const SLOTS_AMOUNT = 9
const SLOTS_SIZE = 20

onready var slotsContainer = $SlotsContainer
onready var disabledSprite = $DisabledSprite

var inventory = []
var items = []
var slotScene = preload("res://party/inventory/InventoryItem.tscn")
var activeSlots
var grabbedItem = null
var isActive = true
var _err

func _ready():
	add_to_group('inventory')
	inventory = load_inventory().slots
	items = load_items().items
	build_inventory()
	update_inventory()
	
func load_inventory():
	var file = File.new()
	file.open('res://data/inventory.json', File.READ)
	var fileContent = parse_json(file.get_as_text())
	file.close()
	return fileContent
	
func load_items():
	var file = File.new()
	file.open('res://data/items.json', File.READ)
	var fileContent = parse_json(file.get_as_text())
	file.close()
	return fileContent

func build_inventory():
	for slot in SLOTS_AMOUNT:
		var slotInstance = slotScene.instance()
		slotInstance.find_node('ItemBg').flip_h = slot % 2 == 0
		slotInstance.position.x = SLOTS_SIZE * slot + slot + 1
		slotInstance.find_node('ItemSprite').hframes = items.size()
		_err = slotInstance.connect("input_event", self, "slot_clicked", [slotInstance, slot])
		slotsContainer.add_child(slotInstance)
	activeSlots = slotsContainer.get_children()

func update_inventory(inverSlots = false):
	var i = 0
	for slot in activeSlots:
		var itemId = inventory[i]
		if itemId != null:
			slot.find_node('ItemSprite').frame = itemId
			slot.find_node('ItemSprite').visible = true
		else:
			slot.find_node('ItemSprite').visible = false
		if inverSlots:
			var slotBg = slot.find_node('ItemBg')
			slotBg.flip_h = !slotBg.flip_h
		i += 1

func slot_clicked(_target, event, _shape, slot, index):
	if event is InputEventMouseButton  and event.button_index == BUTTON_LEFT and event.pressed and isActive:
		var tempGrabbedItem = grabbedItem
		var tempSlotItem = inventory[index]
		# Set slot item
		inventory[index] = tempGrabbedItem
		# Set grabbed item
		grabbedItem = tempSlotItem
		# Set slot sprite visibility
		if inventory[index] != null:
			slot.find_node('ItemSprite').frame = tempGrabbedItem
			slot.find_node('ItemSprite').visible = true
		else:
			slot.find_node('ItemSprite').visible = false
		set_cursor_item()

func set_cursor_item(showtext = true):
	# set cursor sprite visibility
	if grabbedItem != null:
		if showtext:
			var text = items[grabbedItem].name + ' taken.'
			get_tree().call_group('dialogbox', 'displayText', text)
		get_tree().call_group('cursor', 'show_sprite', grabbedItem)
		get_tree().call_group('audiostream', 'play_sound', 'hud', 'grabitem')
	else:
		discard_active_item()
	
func add_item(index, showText = false):
	if grabbedItem != null and inventory.find(null) > -1:
		inventory[inventory.find(null)] = grabbedItem
		update_inventory()
	grabbedItem = index
	set_cursor_item(showText)

func browse_inventory(direction, mode):
	var steps = 1 if mode == 'step' else SLOTS_AMOUNT
	for step in steps:
		if direction == 'Left':
			inventory.push_front(inventory.pop_back())
		else:
			inventory.push_back(inventory.pop_front())
	update_inventory(true)

func discard_active_item():
	grabbedItem = null
	get_tree().call_group('cursor', 'hide_sprite')

func get_active_item():
	if grabbedItem == null:
		return {
			"id": null
		}
	else:
		return items[grabbedItem]

func set_grabbed_item(item):
	grabbedItem = null if item == -1 else item

func _exit_tree():
	for slot in activeSlots:
		slot.queue_free()

func set_active(mode):
	disabledSprite.visible = !mode
	isActive = mode
	get_tree().call_group('inventoryarrows', 'set_active', mode)

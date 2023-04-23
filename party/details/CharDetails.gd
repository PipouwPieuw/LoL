extends Node2D

onready var background = $Background
onready var charName = $Name
onready var close = $Close
onready var slotsContainer = $SlotsContainer

var detailSlot = preload("res://boxes/detailSlot.tscn")

var data = {}
var items = []
var _err

func _ready():
	add_to_group('chardetails')
	visible = false
	background.texture = load("res://assets/sprites/hud/inventory" + data.attributes.inventoryId + ".png")
	charName.text = data.attributes.name
	items = load_items().items
	add_slots()
	_err = close.connect("input_event", self, "close_details")

func load_items():
	var file = File.new()
	file.open('res://data/items.json', File.READ)
	var fileContent = parse_json(file.get_as_text())
	file.close()
	return fileContent

func add_slots():
	for slot in data.equipment:
		var slotData = data.equipment[slot];
		var slotInstance = detailSlot.instance()
#			slotInstance.find_node('ItemBg').visible = false
		slotInstance.position.x = slotData.posX + (slotData.size / 2) - 1
		slotInstance.position.y = slotData.posY + (slotData.size / 2)
		slotInstance.size = slotData.size
		slotInstance.find_node('ItemSprite').hframes = items.size()
		_err = slotInstance.connect("input_event", self, "slot_clicked", [slotInstance, slot])
		slotsContainer.add_child(slotInstance)

func display_details(id):
	if id == data.attributes.id:
		get_tree().call_group('inputs', 'set_move', false)
		visible = true
	else:
		visible = false

func close_details(_viewport, event, _shape_idx):
	if event is InputEventMouseButton  and event.button_index == BUTTON_LEFT and event.pressed:
		get_tree().call_group('viewport', 'show_viewport')
		visible = false
		get_tree().call_group('inputs', 'set_move', true)

func slot_clicked(_target, event, _shape, slot, id):
	if event is InputEventMouseButton  and event.button_index == BUTTON_LEFT and event.pressed:
		# Set slot item
		var tempGrabbedItem = get_tree().get_nodes_in_group("inventory")[0].grabbedItem
		var tempSlotItem = data.equipment[id].item
		
#		# Check if grabbed item is of right type to be dropped into slot
		if tempGrabbedItem == -1 or (tempGrabbedItem > -1 and (items[tempGrabbedItem].type == data.equipment[id].type)):
			data.equipment[id].item = tempGrabbedItem
			get_tree().call_group('inventory', 'set_grabbed_item', tempSlotItem)
			# Set slot sprite visibility
			if data.equipment[id].item > -1:
				slot.find_node('ItemSprite').frame = tempGrabbedItem
				slot.find_node('ItemSprite').visible = true
#				slot.find_node('ItemBg').visible = true
			else:
				slot.find_node('ItemSprite').visible = false
#				slot.find_node('ItemBg').visible = false
			get_tree().call_group('inventory', 'set_cursor_item')
		else:
			var text = items[tempGrabbedItem].equipmentText
			get_tree().call_group('hud', 'displayText', text)


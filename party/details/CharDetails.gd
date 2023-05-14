extends Node2D

onready var background = $Background
onready var charName = $Name
onready var mightValue = $MightValue
onready var protectionValue = $ProtectionValue
onready var close = $Close
onready var slotsContainer = $SlotsContainer

var detailSlot = preload("res://boxes/detailSlot.tscn")

var data = {}
var items = []
var _err

func _ready():
	add_to_group('chardetails')
	initialize()
	add_slots()
	_err = close.connect("input_event", self, "close_action")

func initialize():
	visible = false
	background.texture = load("res://assets/sprites/hud/inventory" + data.attributes.inventoryId + ".png")
	items = load_items().items
	charName.text = data.attributes.name
	mightValue.text = str(data.attributes.might)
	protectionValue.text = str(data.attributes.protection)

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
		slotInstance.type = slotData.type
		slotInstance.find_node('ItemSprite').hframes = items.size()
		_err = slotInstance.connect("input_event", self, "slot_clicked", [slotInstance, slot])
		slotsContainer.add_child(slotInstance)

func display_details(id):
	if id == data.attributes.id:
		get_tree().call_group('inputs', 'set_move', false)
		add_to_group('chardetailsactive')
		visible = true
	else:
		if is_in_group('chardetailsactive'):
			remove_from_group('chardetailsactive')
		visible = false

func close_action(_viewport, event, _shape_idx):
	if event is InputEventMouseButton  and event.button_index == BUTTON_LEFT and event.pressed:
		close_details()

func close_details():
		get_tree().call_group('viewport', 'show_viewport')
		if is_in_group('chardetailsactive'):
			remove_from_group('chardetailsactive')
		visible = false		
		get_tree().call_group('party', 'set_closed')
		get_tree().call_group('inputs', 'set_move', true)
		get_tree().call_group('atlas', 'toggle', true)

func slot_clicked(_target, event, _shape, slot, id):
	if event is InputEventMouseButton  and event.button_index == BUTTON_LEFT and event.pressed:
		# Set slot item
		var tempGrabbedItem = get_tree().get_nodes_in_group("inventory")[0].grabbedItem
		var tempSlotItem = data.equipment[id].item
#		# Check if grabbed item is of right type to be dropped into slot
		if tempGrabbedItem == null or (tempGrabbedItem != null and (items[tempGrabbedItem].type == data.equipment[id].type)):
			data.equipment[id].item = tempGrabbedItem
			get_tree().call_group('inventory', 'set_grabbed_item', tempSlotItem if tempSlotItem != null else -1)
			# Set might attribute
			if tempSlotItem != null and 'might' in items[tempSlotItem] and tempGrabbedItem != null and 'might' in items[tempGrabbedItem]:
				var newVal = items[tempGrabbedItem].might - items[tempSlotItem].might
				var operator = -1 if newVal < 0 else 1
				update_might(abs(newVal), operator)
			elif tempSlotItem != null and 'might' in items[tempSlotItem]:
				update_might(items[tempSlotItem].might, -1)
			elif tempGrabbedItem != null and 'might' in items[tempGrabbedItem]:
				update_might(items[tempGrabbedItem].might)
			# Set protection attribute
			if tempSlotItem != null and 'protection' in items[tempSlotItem] and tempGrabbedItem != null and 'protection' in items[tempGrabbedItem]:
				var newVal = items[tempGrabbedItem].protection - items[tempSlotItem].protection
				var operator = -1 if newVal < 0 else 1
				update_protection(abs(newVal), operator)
			elif tempSlotItem != null and 'protection' in items[tempSlotItem]:
				update_protection(items[tempSlotItem].protection, -1)
			elif tempGrabbedItem != null and 'protection' in items[tempGrabbedItem]:
				update_protection(items[tempGrabbedItem].protection)
			# Set slot sprite visibility
			if data.equipment[id].item != null:
				slot.find_node('ItemSprite').frame = tempGrabbedItem
				slot.find_node('ItemSprite').visible = true
				slot.slotPlaceholder.visible = false
			else:
				slot.find_node('ItemSprite').visible = false
				slot.slotPlaceholder.visible = true
			get_tree().call_group('inventory', 'set_cursor_item')
		else:
			var text = items[tempGrabbedItem].equipmentText
			get_tree().call_group('dialogbox', 'displayText', text)

func update_might(value, operator = 1):
	var baseMight = data.attributes.might
	var updatedMight = baseMight + (value * operator)
	data.attributes.might = updatedMight
	animate_number(baseMight, value, operator, mightValue)

func update_protection(value, operator = 1):
	var baseProtection = data.attributes.protection
	var updatedProtection = baseProtection + (value * operator)
	data.attributes.protection = updatedProtection
	animate_number(baseProtection, value, operator, protectionValue)

func animate_number(baseValue, increment, operator, label):
	var counter = baseValue + operator
	if operator > 0:
		while(counter < baseValue + increment):
			counter = clamp(counter + operator, baseValue, baseValue + increment)
			label.text = str(counter)
			yield(get_tree().create_timer(0.01), "timeout")
	else:
		while(counter > baseValue - increment):
			counter = clamp(counter + operator, baseValue - increment, baseValue)
			label.text = str(counter)
			yield(get_tree().create_timer(0.01), "timeout")

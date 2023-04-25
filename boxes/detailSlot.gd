extends Area2D

onready var slotShape = $SlotShape
onready var slotPlaceholder = $slotPlaceholder

var size
var type

func _ready():
	# Set placeholder
	slotPlaceholder.texture = load("res://assets/sprites/hud/" + type + "Placeholder.png")
	# Build shape
	var shape = RectangleShape2D.new()
	shape.set_extents(Vector2(size / 2, size / 2))
	slotShape.set_shape(shape)

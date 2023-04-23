extends Area2D

onready var slotShape = $SlotShape

var size

func _ready():
	# Build shape
	var shape = RectangleShape2D.new()
	shape.set_extents(Vector2(size / 2, size / 2))
	slotShape.set_shape(shape)

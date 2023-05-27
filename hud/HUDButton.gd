extends Area2D

export var buttonWidth: int = 37
export var labelText: String

onready var darkBorder = $DarkBorder
onready var lightBorder = $LightBorder
onready var background = $Background
onready var collisionShape = $CollisionShape2D
onready var label = $Label

func _ready():
	darkBorder.rect_position.x = -buttonWidth
	darkBorder.rect_size.x = buttonWidth * 2
	lightBorder.rect_position.x = -buttonWidth + 1
	lightBorder.rect_size.x = buttonWidth * 2 - 1
	background.rect_position.x = -buttonWidth + 1
	background.rect_size.x = buttonWidth * 2 - 2
	collisionShape.shape.extents = Vector2(buttonWidth, 5)
	label.text = labelText


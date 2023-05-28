extends Area2D

export var buttonWidth: int = 37
export var labelText: String

onready var darkBorder = $DarkBorder
onready var lightBorder = $LightBorder
onready var background = $Background
onready var collisionShape = $CollisionShape
onready var label = $Label
onready var disabledSprite = $DisabledSprite

func _ready():
	darkBorder.rect_position.x = -buttonWidth
	darkBorder.rect_size.x = buttonWidth * 2
	lightBorder.rect_position.x = -buttonWidth + 1
	lightBorder.rect_size.x = buttonWidth * 2 - 1
	background.rect_position.x = -buttonWidth + 1
	background.rect_size.x = buttonWidth * 2 - 2
	label.text = labelText
	disabledSprite.position.x = -buttonWidth
	disabledSprite.region_rect = Rect2(0, 0, buttonWidth * 2, 9)
	# Build shape
	var shape = RectangleShape2D.new()
	shape.set_extents(Vector2(buttonWidth, 5))
	collisionShape.set_shape(shape)

func set_disabled(mode):
	collisionShape.disabled = mode
	disabledSprite.visible = mode

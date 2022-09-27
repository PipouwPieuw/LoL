extends Node2D

onready var wallFront = $WallFront
onready var wallLeft = $WallLeft
onready var wallRight = $WallRight

func _ready():
	add_to_group("viewport")

func update_walls(data):
	wallFront.visible = data.wallFront
	wallLeft.visible = data.wallLeft
	wallRight.visible = data.wallRight

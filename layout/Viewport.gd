extends Node2D

onready var wallFront   = $WallFront
onready var wallLeft    = $WallLeft
onready var wallRight   = $WallRight
onready var wallFrontU  = $WallFrontU
onready var wallLeftU   = $WallLeftU
onready var wallRightU  = $WallRightU
onready var wallFrontUU = $WallFrontUU
onready var wallLeftUU  = $WallLeftUU
onready var wallRightUU = $WallRightUU

func _ready():
	add_to_group("viewport")

func update_walls(data):
	# Current cell
	wallFront.visible = data.currentCell.wallFront
	wallLeft.visible = data.currentCell.wallLeft
	wallRight.visible = data.currentCell.wallRight
	# Current cell + U
	wallFrontU.visible = data.currentCellU.wallFront
	wallLeftU.visible = data.currentCellU.wallLeft
	wallRightU.visible = data.currentCellU.wallRight
	# Current cell + U + U
	wallFrontUU.visible = data.currentCellUU.wallFront
	wallLeftUU.visible = data.currentCellUU.wallLeft
	wallRightUU.visible = data.currentCellUU.wallRight

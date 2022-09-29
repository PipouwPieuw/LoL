extends Control

onready var floorSprite   = $Floor
onready var wallFront     = $WallFront
onready var wallLeft      = $WallLeft
onready var wallRight     = $WallRight
onready var wallFrontL    = $WallFrontL
onready var wallFrontR    = $WallFrontR
onready var wallFrontU    = $WallFrontU
onready var wallFrontUL   = $WallFrontUL
onready var wallFrontUR   = $WallFrontUR
onready var wallLeftU     = $WallLeftU
onready var wallRightU    = $WallRightU
onready var wallFrontUU   = $WallFrontUU
onready var wallFrontUUL  = $WallFrontUUL
onready var wallLeftUUL   = $WallLeftUUL
onready var wallFrontUULL = $WallFrontUULL
onready var wallFrontUUR  = $WallFrontUUR
onready var wallRightUUR  = $WallRightUUR
onready var wallFrontUURR = $WallFrontUURR
onready var wallLeftUU    = $WallLeftUU
onready var wallRightUU   = $WallRightUU
onready var wallLeftUUU   = $WallLeftUUU
onready var wallRightUUU  = $WallRightUUU

func _ready():
	add_to_group("viewport")

func update_walls(data):
	# Current cell
	wallFront.visible = data.currentCell.wallFront
	wallLeft.visible  = data.currentCell.wallLeft
	wallRight.visible = data.currentCell.wallRight
	# Current cell + L
	wallFrontL.visible = data.currentCellL.wallFront
	# Current cell + R
	wallFrontR.visible = data.currentCellR.wallFront
	# Current cell + U
	wallFrontU.visible = data.currentCellU.wallFront
	wallLeftU.visible  = data.currentCellU.wallLeft
	wallRightU.visible = data.currentCellU.wallRight
	# Current cell + U + L
	wallFrontUL.visible = data.currentCellUL.wallFront
	# Current cell + U + R
	wallFrontUR.visible = data.currentCellUR.wallFront
	# Current cell + U + U
	wallFrontUU.visible = data.currentCellUU.wallFront
	wallLeftUU.visible  = data.currentCellUU.wallLeft
	wallRightUU.visible = data.currentCellUU.wallRight
	# Current cell + U + U + L
	wallFrontUUL.visible = data.currentCellUUL.wallFront
	wallLeftUUL.visible  = data.currentCellUUL.wallLeft
	# Current cell + U + U + L + L
	wallFrontUULL.visible = data.currentCellUULL.wallFront
	# Current cell + U + U + R
	wallFrontUUR.visible = data.currentCellUUR.wallFront
	wallRightUUR.visible = data.currentCellUUR.wallRight
	# Current cell + U + U + R + R
	wallFrontUURR.visible = data.currentCellUURR.wallFront
	# Current cell + U + U + U
	wallLeftUUU.visible  = data.currentCellUUU.wallLeft
	wallRightUUU.visible = data.currentCellUUU.wallRight

func update_floor():
	floorSprite.flip_h = !floorSprite.flip_h

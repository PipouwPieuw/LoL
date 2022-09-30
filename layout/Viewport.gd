extends Control

onready var ceilingSprite = $Ceiling
onready var floorSprite   = $Floor
onready var wallFront     = $Walls/WallFront
onready var wallLeft      = $Walls/WallLeft
onready var wallRight     = $Walls/WallRight
onready var wallFrontL    = $Walls/WallFrontL
onready var wallFrontR    = $Walls/WallFrontR
onready var wallFrontU    = $Walls/WallFrontU
onready var wallFrontUL   = $Walls/WallFrontUL
onready var wallFrontUR   = $Walls/WallFrontUR
onready var wallLeftU     = $Walls/WallLeftU
onready var wallRightU    = $Walls/WallRightU
onready var wallFrontUU   = $Walls/WallFrontUU
onready var wallFrontUUL  = $Walls/WallFrontUUL
onready var wallLeftUUL   = $Walls/WallLeftUUL
onready var wallFrontUULL = $Walls/WallFrontUULL
onready var wallFrontUUR  = $Walls/WallFrontUUR
onready var wallRightUUR  = $Walls/WallRightUUR
onready var wallFrontUURR = $Walls/WallFrontUURR
onready var wallLeftUU    = $Walls/WallLeftUU
onready var wallRightUU   = $Walls/WallRightUU
onready var wallLeftUUU   = $Walls/WallLeftUUU
onready var wallRightUUU  = $Walls/WallRightUUU

onready var walls = $Walls

var sprites = {}
var spriteBasePath = 'res://assets/sprites/layout'
var spritePath = ''
var currentLayout = ''
#var wallNodes = {}

func _ready():
	add_to_group("viewport")
#	get_walls()

# Get all wall nodes
#func get_walls():
#	for wall in walls.get_children():
#		wallNodes[wall.get_name()] = wall

# Set new layout for sprites
func update_layout(newLayout):
	currentLayout = newLayout
	spritePath = spriteBasePath + '/' + currentLayout + '/'
	preload_sprites()
	ceilingSprite.texture = sprites['ceiling']
	floorSprite.texture = sprites['floor']

# Load all sprites from current layout in dictionary for later use
func preload_sprites():
	var dir = Directory.new()
	dir.open(spritePath)
	dir.list_dir_begin()
	while true:
		var file_name = dir.get_next()
		if file_name == "":
			#break the while loop when get_next() returns ""
			break
		elif file_name.ends_with('.png'):
			var spriteKey = file_name.replace(".png", "")
			sprites[spriteKey] = load(spritePath + "/" + file_name)
	dir.list_dir_end()

# Update wall visibility and sprite
func update_walls(data):
#	for wall in wallNodes.keys():
#		var wallName = wall
#		var wallDir = wallName
#		var wallOffset = ''
#		if wallName.find('_') != -1:
#			var nameSplit = wallName.split("_")
#			wallDir = nameSplit[0]
#			if wallDir != 'wallFront':
#				wallOffset = nameSplit[1]
#		var walllVisibility = data['currentCell' + wallOffset][wallDir]
#		wallNodes[wall].visible = walllVisibility
#		if walllVisibility:
#			wallNodes[wall].texture = sprites[wallDir + data['currentCell' + wallOffset][wallDir + 'Type'] + wallOffset]
	# Current cell
	wallFront.visible = data.currentCell.wallFront
	wallFront.texture = sprites['wallFront' + data.currentCell.wallFrontType]
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

func update_ceiling_floor():
	floorSprite.flip_h   = !floorSprite.flip_h
	ceilingSprite.flip_h = !ceilingSprite.flip_h

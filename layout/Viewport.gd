extends Control

onready var ceilingSprite = $Ceiling
onready var floorSprite   = $Floor
onready var walls = $Walls

var sprites = {}
var spriteBasePath = 'res://assets/sprites/layout'
var spritePath = ''
var currentLayout = ''
var wallNodes = {}

func _ready():
	add_to_group("viewport")
	get_walls()

# Get all wall nodes
func get_walls():
	for wall in walls.get_children():
		# Process string
		var wallName = wall.get_name().replace('tU', 't_U').replace('tL', 't_L').replace('tR', 't_R')
		wallName[0] = 'w'
		var wallDirCell = wallName
		var wallDirSprite =  wallName.split("_")[0].replace('Left', 'Side').replace('Right', 'Side')
		var wallOffsetCell = ''
		var wallOffsetSprite = ''
		if wallName.find('_') != -1:
			var nameSplit = wallName.split("_")
			wallDirCell = nameSplit[0]
			wallOffsetCell = nameSplit[1]
			wallOffsetSprite = wallOffsetCell
			if wallDirCell == 'wallFront':
				wallOffsetSprite = wallOffsetSprite.replace('R', '').replace('L', '')
			if wallDirSprite == 'wallSide':
				wallOffsetSprite = wallOffsetSprite.replace('UUR', 'UUS').replace('UUL', 'UUS')
					
		# Save wall data in object
		wallNodes[wall.get_name()] = {}
		wallNodes[wall.get_name()].sprite = wall
		wallNodes[wall.get_name()].dirCell = wallDirCell
		wallNodes[wall.get_name()].dirSprite = wallDirSprite
		wallNodes[wall.get_name()].offsetCell = wallOffsetCell
		wallNodes[wall.get_name()].offsetSprite = wallOffsetSprite

# Set new layout for sprites
func update_layout(newLayout):
	currentLayout = newLayout
	spritePath = spriteBasePath + '/' + currentLayout + '/'
	preload_sprites()
	ceilingSprite.texture = sprites['Ceiling']
	floorSprite.texture = sprites['Floor']

# Load all sprites from current layout in dictionary for later use
func preload_sprites():
	var dir = Directory.new()
	dir.open(spritePath)
	dir.list_dir_begin()
	while true:
		var file_name = dir.get_next()
		if file_name == "":
			break
		elif file_name.ends_with('.png'):
			var spriteKey = file_name.replace(".png", "")
			sprites[spriteKey] = load(spritePath + "/" + file_name)
	dir.list_dir_end()

# Update wall visibility and sprite
func update_walls(data):
	for wallName in wallNodes.keys():
		print(wallName)
		var wall = wallNodes[wallName]
		# Set wall sprite
		var walllVisibility = data['currentCell' + wall.offsetCell][wall.dirCell]
		wall.sprite.visible = walllVisibility
		if walllVisibility:
			if wall.offsetSprite == 'UUU':
				wall.sprite.texture = sprites['wallSideDefaultUUU']
			else:
				wall.sprite.texture = sprites[wall.dirSprite + data['currentCell' + wall.offsetCell][wall.dirCell + 'Type'] + wall.offsetSprite]

func update_ceiling_floor():
	floorSprite.flip_h   = !floorSprite.flip_h
	ceilingSprite.flip_h = !ceilingSprite.flip_h

extends Control

onready var textures = $Textures
onready var ceilingSprite = $Textures/Front/Ceiling
onready var floorSprite   = $Textures/Front/Floor
onready var ceilingSpriteSide = $Textures/Side/Ceiling
onready var floorSpriteSide   = $Textures/Side/Floor
onready var viewFront = $Textures/Front
onready var viewSide = $Textures/Side
onready var walls = $Textures/Front/Walls
onready var wallsSide = $Textures/Side/Walls
onready var zonesContainer = $Textures/Front/Walls/WallFront/InteractionZones
onready var triggerZone = preload("res://boxes/triggerZone.tscn")

var sprites = {}
var spriteBasePath = 'res://assets/sprites/layout'
var spritePath = ''
var currentLayout = ''
var spriteSheetFrames = 0
var wallNodes = {}
var wallNodesSide = {}
var moveDirection = ''
var bumpAnimation = false
var data = {}
var interationsData = {}
var wallAnimation = false

func _ready():
	add_to_group("viewport")

func _physics_process(_delta):
	# Move animations
	if moveDirection != '':
		if moveDirection == 'up':
			textures.rect_scale.x += .1
			textures.rect_scale.y += .1
			if textures.rect_scale.x >= 1.6:
				end_move_up_down()
				update_walls(wallNodes)
		elif moveDirection == 'down':
			if textures.rect_scale.x == 1:
				update_walls(wallNodes)
				textures.rect_scale.x = 1.6
				textures.rect_scale.y = 1.6
			textures.rect_scale.x -= .1
			textures.rect_scale.y -= .1
			if textures.rect_scale.x <= 1:
				end_move_up_down()
		elif moveDirection == 'right':
			if viewFront.rect_position.x == 0:
				update_walls(wallNodesSide)
				viewSide.rect_position.x = 128
			viewFront.rect_position.x -= 22
			viewSide.rect_position.x -= 22
			if viewSide.rect_position.x <= 0:
				update_walls(wallNodes)
				end_move_left_right()
		elif moveDirection == 'left':
			if viewFront.rect_position.x == 0:
				update_walls(wallNodesSide)
				viewSide.rect_position.x = -128
			viewFront.rect_position.x += 22
			viewSide.rect_position.x += 22
			if viewSide.rect_position.x >= 0:
				update_walls(wallNodes)
				end_move_left_right()
		elif moveDirection == 'turnright':
			move_animation_turn(-1)
		elif moveDirection == 'turnleft':
			move_animation_turn(1)
	# Wall bump animation
	elif bumpAnimation:
		textures.rect_scale.x += .1
		textures.rect_scale.y += .1
		if textures.rect_scale.x >= 1.4:
			bumpAnimation = false
			textures.rect_scale.x = 1
			textures.rect_scale.y = 1

func end_move_up_down():
	moveDirection = ''
	textures.rect_scale.x = 1
	textures.rect_scale.y = 1

func end_move_left_right():
	moveDirection = ''
	yield(get_tree(),"idle_frame")
	yield(get_tree(),"idle_frame")
	viewFront.rect_position.x = 0
	viewSide.rect_position.x = -176

func move_animation_turn(mode):
	if viewFront.rect_position.x == 0:
		update_walls(wallNodesSide)
		viewSide.rect_position.x = -176 * mode
		viewSide.rect_pivot_offset.x = 176 if mode == 1 else 0
		viewSide.rect_scale.x = 1.9
		viewFront.rect_pivot_offset.x = 0 if mode == 1 else 176
	viewSide.rect_scale.x -= .15
	viewFront.rect_position.x += 29 * mode
	viewSide.rect_position.x += 29 * mode
	viewFront.rect_scale.x += .15
	if viewSide.rect_scale.x <= 1:
		update_walls(wallNodes)
		moveDirection = ''
		viewFront.rect_scale.x = 1
		viewSide.rect_scale.x = 1
		viewFront.rect_position.x = 0
		viewSide.rect_position.x = -176

func start_move(dir, moveData):
	data = moveData
	moveDirection = dir

func update_viewport(newData):
	data = newData
	update_walls(wallNodes)

# Get all wall nodes
func get_walls(wallObject):
	var result = {}
	for wall in wallObject.get_children():
		wall.hframes = spriteSheetFrames
		# Set walls sprites
		var wallName = wall.get_name()
		wall.texture = sprites[wallName]
		# Process string
		wallName = wallName.replace('tU', 't_U').replace('tL', 't_L').replace('tR', 't_R')
		wallName[0] = 'w'
		var wallDirCell = wallName
		var wallOffsetCell = ''
		if wallName.find('_') != -1:
			var nameSplit = wallName.split("_")
			wallDirCell = nameSplit[0]
			wallOffsetCell = nameSplit[1]
		# Save wall data in object
		result[wall.get_name()] = {}
		result[wall.get_name()].sprite = wall
		result[wall.get_name()].dirCell = wallDirCell
		result[wall.get_name()].offsetCell = wallOffsetCell
	return result;

# Set new layout for sprites
func update_layout(newLayout, framesAmount):
	currentLayout = newLayout
	spritePath = spriteBasePath + '/' + currentLayout + '/'
	spriteSheetFrames = framesAmount
	preload_sprites()
	wallNodes = get_walls(walls)
	wallNodesSide = get_walls(wallsSide)
	ceilingSprite.texture = sprites['Ceiling']
	floorSprite.texture = sprites['Floor']
	ceilingSpriteSide.texture = sprites['Ceiling']
	floorSpriteSide.texture = sprites['Floor']
	ceilingSpriteSide.flip_h = true
	floorSpriteSide.flip_h = true

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
func update_walls(wallObject):
	wallAnimation = false
	yield(get_tree(),"idle_frame")
	for wallName in wallObject.keys():
		var wall = wallObject[wallName]
		# Delete previous interaction zones
		if wallName == 'WallFront':
			for zone in zonesContainer.get_children():
				zone.disconnect_signal()
				yield(get_tree(),"idle_frame")
				zonesContainer.remove_child(zone)
				zone.queue_free()
		# Set wall sprite
		var spriteIndex = data['currentCell' + wall.offsetCell][wall.dirCell + 'SpriteIndex']
		# Animations
		if typeof(spriteIndex) == TYPE_ARRAY:
			wall.sprite.visible = true
			wall.sprite.frame = spriteIndex[0][0]
			wallAnimation = true
			animateWall(wall, spriteIndex)
		# No wall
		elif spriteIndex == -1:
			wall.sprite.visible = false
		# Wall texture
		else:
			wall.sprite.visible = true
			wall.sprite.frame = spriteIndex
			# Create interaction zones
		if wallName == 'WallFront':
			if !data['currentCell'].InteractionZones.empty():
				zonesContainer.visible = true
				for zone in data['currentCell'].InteractionZones:
					var zoneArea = triggerZone.instance()
					var zoneShape = zoneArea.find_node('zoneShape')
					var triggerPos = zone.triggerPos
					zoneArea.triggerType = zone.triggerType
					zoneArea.effect = zone.effect
					if ['toggleDoor', 'keyhole'].find(zone.effect) > -1:
						zoneArea.targetCell = zone.targetCell
					if ['displayText', 'keyhole'].find(zone.effect) > -1:
						zoneArea.text = zone.text
					if ['keyhole'].find(zone.effect) > -1:
						zoneArea.invalidText = zone.invalidText
					if ['keyhole'].find(zone.effect) > -1:
						zoneArea.acceptedItems = zone.acceptedItems
					zoneArea.position.x = triggerPos[0] + triggerPos[2] / 2
					zoneArea.position.y = triggerPos[1] + triggerPos[3] / 2
					zoneShape.shape.extents.x = triggerPos[2] / 2
					zoneShape.shape.extents.y = triggerPos[3] / 2
					zoneArea.attachedNode = self
					zonesContainer.add_child(zoneArea)
			else:
				zonesContainer.visible = false

func update_ceiling_floor():
	floorSprite.flip_h   = !floorSprite.flip_h
	ceilingSprite.flip_h = !ceilingSprite.flip_h
	floorSpriteSide.flip_h   = !floorSpriteSide.flip_h
	ceilingSpriteSide.flip_h = !ceilingSpriteSide.flip_h

func bump_forward():
	bumpAnimation = true

func sendInteraction(_viewport, event, _shape_idx, effect, args):
	if event is InputEventMouseButton  and event.button_index == BUTTON_LEFT and event.pressed:
		get_tree().call_group('controller', effect, args)

func animateWall(wall, framesData):
	var frames = framesData[0]
	var speed = framesData[1]
	var i = 0
	while wallAnimation:
		i += 1
		if i == speed * 2:
			var frame = frames.pop_front()
			frames.append(frame)
			wall.sprite.frame = frame
			i = 0
		yield(get_tree(),"idle_frame")

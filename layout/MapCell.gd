extends Node2D

onready var wallsSprite = $WallsSprite
onready var innerSprite = $innerSprite

var data = {}
var wallsCode = ''
var explored = false
var spritesPath = 'res://assets/sprites/map'

func _ready():
	set_sprites()

func set_sprites():
	var walls = ['wallLeft', 'wallBack', 'wallRight', 'wallFront']
	var res = ""
	while walls.size() > 0:
		var wall = walls.pop_back()
		# Check if wall has sprite  and sprite is not door
		if typeof(data.wallAttr[wall].spriteIndex) != TYPE_ARRAY and data.wallAttr[wall].spriteIndex != -1 and !(data.wallAttr[wall].has('isDoor') and data.wallAttr[wall].isDoor):
			res += '1' 
		else:
			res +=  '0'
	wallsCode = res
	if ![''].has(res):
		set_walls()
		if data.type == 'D':
			innerSprite.texture = load(spritesPath + '/door' + res + '.png')
			innerSprite.visible = true
	# Check for special wall types
	var wallsDir = ['wallFront', 'wallRight', 'wallBack', 'wallLeft']
	while wallsDir.size() > 0:
		var currentWall = wallsDir.pop_back()
		if data.wallAttr[currentWall].has('wallType'):
			print(wallsCode)
			add_sprite(data.wallAttr[currentWall].wallType, currentWall)

func set_walls():
	wallsSprite.texture = load(spritesPath + '/walls' + wallsCode + '.png')

func add_sprite(type, wall):
	if  ['up', 'down', 'plate', 'pit', 'secret', 'teleport'].has(type):
		innerSprite.texture = load(spritesPath + '/' + type + '.png')
		innerSprite.visible = true
	elif  ['niche', 'button', 'chest'].has(type):
		var sprite = Sprite.new()
		sprite.centered = false
		sprite.texture = load(spritesPath + '/' + type + '.png')
		# Niche
		if type == 'niche':
			if wall == 'wallFront':
				sprite.position.x = 0
				sprite.position.y = -1
				wallsCode[0] = '0'
				set_walls()
			elif wall == 'wallRight':
				sprite.texture = load(spritesPath + '/nicheSide.png')
				sprite.position.x = 6
				sprite.position.y = 0
				sprite.flip_h = true
				wallsCode[1] = '0'
				set_walls()
			elif wall == 'wallBack':
				sprite.flip_v = true
				sprite.position.x = 0
				sprite.position.y = 5
				wallsCode[2] = '0'
				set_walls()
			elif wall == 'wallLeft':
				sprite.texture = load(spritesPath + '/nicheSide.png')
				sprite.position.x = -1
				sprite.position.y = 0
				wallsCode[3] = '0'
				set_walls()
		# Button / level
		if type == 'button':
			if wall == 'wallFront':
				sprite.position.x = 3
				sprite.position.y = -2
			elif wall == 'wallRight':
				sprite.rotation_degrees = 90
				sprite.position.x = 9
				sprite.position.y = 2
			elif wall == 'wallBack':
				sprite.position.x = 3
				sprite.position.y = 5
			elif wall == 'wallLeft':
				sprite.rotation_degrees = 270
				sprite.position.x = -2
				sprite.position.y = 3
		add_child(sprite)

func set_explored():
	explored = true
	visible = true

extends Node2D

onready var wallsSprite = $WallsSprite
onready var innerSprite = $innerSprite

var data = {}
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
	if !['', '0000'].has(res):
		wallsSprite.texture = load(spritesPath + '/walls' + res + '.png')
		if data.type == 'D':
			innerSprite.texture = load(spritesPath + '/door' + res + '.png')

func set_explored():
	explored = true
	visible = true

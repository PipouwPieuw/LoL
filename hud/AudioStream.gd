extends Node2D

onready var music = $Music
onready var soundEffect1 = $SoundEffect1
onready var soundEffect2 = $SoundEffect2

var soundLibrary = {}

func _ready():
	add_to_group('audiostream')
	preload_sounds('hud')
	preload_sounds('layout')

func preload_sounds(folder):
	soundLibrary[folder] = {}
	var dir = Directory.new()
	var folderPath = 'res://assets/sounds/' + folder + '/'
	dir.open(folderPath)
	dir.list_dir_begin()
	while true:
		var fileName = dir.get_next()
		if fileName == "":
			break
		elif fileName.ends_with('.wav'):
			var soundName = fileName.replace(".wav", "")
			soundLibrary[folder][soundName] = load(folderPath + "/" + fileName)
	dir.list_dir_end()

func play_sound(type, sound):
	if type in soundLibrary and sound in soundLibrary[type]:
		var soundPlayer =  soundEffect1 if !soundEffect1.playing else soundEffect2
		soundPlayer.stream = soundLibrary[type][sound]
		soundPlayer.play()

func play_music(musicName):
	var musicFile = load('res://assets/musics/' + musicName + '.ogg')
	music.stream = musicFile
	music.play()

extends Node2D

onready var music = $Music
onready var soundEffect = $SoundEffect

func _ready():
	add_to_group('audiostream')

func play_sound(type, sound):
	var audioFile = "res://assets/sounds/" + type + "/" + sound + ".wav"
	if File.new().file_exists(audioFile):
		var sfx = load(audioFile) 
		soundEffect.stream = sfx
		soundEffect.play()

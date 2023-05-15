extends AudioStreamPlayer

var _err

func _ready():
	add_to_group('soundeffects')
	_err = self.connect('finished', self, 'kill')

func kill():
	queue_free()

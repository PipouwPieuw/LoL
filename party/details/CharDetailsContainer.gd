extends Node2D

onready var detailsNode = preload("res://party/details/CharDetails.tscn")

func _ready():
	add_to_group('chardetailscontainer')

func add_details(data):
	var detailsInstance = detailsNode.instance()
	detailsInstance.data = data
	add_child(detailsInstance)

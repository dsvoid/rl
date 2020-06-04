extends Node2D

var RogueLight = preload("res://scenes/RogueLight.tscn")
var emits_light = false
var in_world = true
var tile = Vector2()


func _ready():
	pass


func set_light():
	var light = RogueLight.instance()
	add_child(light)

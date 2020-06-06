extends Entity
class_name Item


var RogueLight = preload("res://scenes/RogueLight.tscn")


func set_light():
	var light = RogueLight.instance()
	add_child(light)

extends Node2D
class_name Actor


var tile = Vector2()
var is_moving = false
var TILE_WIDTH
var TILE_HEIGHT


func _ready():
	TILE_WIDTH = get_node("/root/Global").TILE_WIDTH
	TILE_HEIGHT = get_node("/root/Global").TILE_HEIGHT
	tile.x = position.x / TILE_WIDTH
	tile.y = position.y / TILE_HEIGHT
	get_parent().tilev(tile).actor = self


# child Tween node signals to this function when a tween is completed
func _on_ActorTween_completed(object, key):
	is_moving = false

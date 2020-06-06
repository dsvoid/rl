extends Node2D


var tile = Vector2()
var TILE_WIDTH
var TILE_HEIGHT

func _ready():
	TILE_WIDTH = get_node("/root/Global").TILE_WIDTH
	TILE_HEIGHT = get_node("/root/Global").TILE_HEIGHT
	tile.x = position.x / TILE_WIDTH
	tile.y = position.y / TILE_HEIGHT
	get_parent().tilev(tile).items.append(self)


#func _process(delta):
#	pass

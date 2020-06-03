extends TileMap


func _ready():
	for i in range(get_parent().width):
		for j in range(get_parent().height):
			set_cell(i,j,1)


func apply_visibility(old_tiles, new_tiles):
	for i in range(old_tiles.size()):
		var tile = old_tiles[i]
		if in_bounds(tile):
			set_cellv(tile,1)
	for i in range(new_tiles.size()):
		var tile = new_tiles[i]
		if in_bounds(tile):
			set_cellv(tile,0)

func in_bounds(tile): # TODO: is this even worth doing?
	return tile.x > -1 && tile.x < get_parent().width && tile.y > -1 && tile.y < get_parent().height

#func _process(delta):
#	pass

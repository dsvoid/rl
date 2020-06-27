extends "Vision.gd"
class_name RogueLight

var strength
var light_id


func _init(r=7,s=6):
	strength = s
	radius = r


func _ready():
	light_id = Global.level.new_light_id
	Global.level.new_light_id += 1


func set_source(source_tile):
	source = Vector3(source_tile.x, source_tile.y, light_id)


func add_tile(tile):
	var source = get_parent().tile
	var xdiff = abs(tile.x - source.x)
	var ydiff = abs(tile.y - source.y)
	var dist = sqrt(xdiff*xdiff + ydiff*ydiff)
	var light_level = floor(strength - (strength * dist/radius))
	if !visible_tiles.has(tile):
		visible_tiles[tile] = {
			"faces": [false,false,false,false], # up, down, left, right face
			"light_level": light_level
		}
		if tile == get_parent().tile:
			visible_tiles[tile]["faces"] = [true,true,true,true]


func set_seen_faces(tile):
	var v = Vector2(source.x-tile.x,source.y-tile.y)
	if v.y < 0 && !has_vision_blocker_actual(Vector2(tile.x,tile.y-1)):
		visible_tiles[tile]["faces"][0] = true
	if v.y > 0 && !has_vision_blocker_actual(Vector2(tile.x,tile.y+1)):
		visible_tiles[tile]["faces"][1] = true
	if v.x < 0 && !has_vision_blocker_actual(Vector2(tile.x-1,tile.y)):
		visible_tiles[tile]["faces"][2] = true
	if v.x > 0 && !has_vision_blocker_actual(Vector2(tile.x+1,tile.y)):
		visible_tiles[tile]["faces"][3] = true


func has_vision_blocker_actual(actual_tile):
	var tile = Global.level.tilev(actual_tile)
	if tile && tile.obstacle && tile.obstacle.blocks_light:
		return true
	return false


func has_vision_blocker(relative_tile):
	var tile = Global.level.tilev(get_actual_tile(relative_tile))
	if tile && tile.obstacle && tile.obstacle.blocks_light:
		return true
	return false

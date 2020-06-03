extends Node2D

export (PackedScene) var TileBGSprite
var TILE_WIDTH
var TILE_HEIGHT
var observer
var tile_bgs = []
var light_levels_bg = [
	"#18152e",
	"#31282d",
	"#4a3c2d",
	"#63502d",
	"#7c632c",
	"#95772c",
	"#af8b2c"
]
var light_levels_fg = [
	"#7569ba",
	"#8b80c1",
	"#a197c8",
	"#b7aed0",
	"#cdc5d7",
	"#e3dcde",
	"#f9f4e6"
]

func _ready():
	observer = get_parent().get_node("Player")
	TILE_WIDTH = get_node("/root/Global").TILE_WIDTH
	TILE_HEIGHT = get_node("/root/Global").TILE_HEIGHT
	for i in range(get_parent().width):
		tile_bgs.append([])
		for j in range(get_parent().height):
			var tile_bg = TileBGSprite.instance()
			tile_bg.position.x = i * TILE_WIDTH
			tile_bg.position.y = j * TILE_HEIGHT
			tile_bg.modulate = Color("#000000")
			add_child(tile_bg)
			tile_bgs[i].append(tile_bg)


func init_vision():
	for i in range(get_parent().width):
		for j in range(get_parent().height):
			var tile = get_parent().tile(i,j)
			if tile.actor:
				tile.actor.get_node("ActorSprite").set("visible", false)
			if tile.obstacle && !tile.obstacle.seen_before:
				tile.obstacle.get_node("ObstacleSprite").set("visible", false)


func apply_vision(old_visible_tiles, new_visible_tiles):
	for i in old_visible_tiles:
		var tile = get_parent().tilev(i)
		tile_bgs[i.x][i.y].modulate = Color("#000000")
		if tile.actor:
			tile.actor.get_node("ActorSprite").set("visible", false)
		if tile.obstacle:
			if !tile.obstacle.seen_before:
				tile.obstacle.get_node("ObstacleSprite").set("visible", false)
			tile.obstacle.get_node("ObstacleSprite").modulate = Color("#555555")
	for i in new_visible_tiles:
		var tile = get_parent().tilev(i)
		light_tile(tile,i)
		tile_bgs[i.x][i.y].modulate = Color(light_levels_bg[tile.light_level])
		if tile.actor:
			tile.actor.get_node("ActorSprite").set("visible", true)
			tile.actor.get_node("ActorSprite").modulate = Color(light_levels_fg[tile.light_level])
		if tile.obstacle:
			tile.obstacle.get_node("ObstacleSprite").set("visible", true)
			tile.obstacle.get_node("ObstacleSprite").modulate = Color(light_levels_fg[tile.light_level])
			tile.obstacle.seen_before = true


func apply_light(old_visible_tiles, new_visible_tiles):
	for i in old_visible_tiles:
		var tile = get_parent().tilev(i)
		tile.lights.erase(new_visible_tiles[i].source)
	for i in new_visible_tiles:
		var tile = get_parent().tilev(i)
		tile.lights[new_visible_tiles[i].source] = {
			"light_level": new_visible_tiles[i].light_level,
			"faces": new_visible_tiles[i].faces
		}


func light_tile(tile,location):
	tile.light_level = 0
	if !tile.obstacle:
		for i in tile.lights:
			tile.light_level += tile.lights[i].light_level
	else:
		for i in tile.lights:
			var vision_faces = observer.get_node("Vision").visible_tiles[location]
			var light_faces = tile.lights[i].faces
			if ((vision_faces[0] && light_faces[0])
			 || (vision_faces[1] && light_faces[1])
			 || (vision_faces[2] && light_faces[2])
			 || (vision_faces[3] && light_faces[3])):
				tile.light_level += tile.lights[i].light_level
	tile.light_level = min(tile.light_level,6)

extends Node2D

var TileBGSprite = preload("res://scenes/TileBGSprite.tscn")
var observer
var tile_bgs = []
var light_levels_bg = [
	Color("#18152e"),
	Color("#31282d"),
	Color("#4a3c2d"),
	Color("#63502d"),
	Color("#7c632c"),
	Color("#95772c"),
	Color("#af8b2c")
]
var light_levels_fg = [
	Color("#7569ba"),
	Color("#8b80c1"),
	Color("#a197c8"),
	Color("#b7aed0"),
	Color("#cdc5d7"),
	Color("#e3dcde"),
	Color("#f9f4e6")
]
var black = Color("#000000")
var grey = Color("#555555")


func init_vision():
	for i in range(get_parent().width):
		tile_bgs.append([])
		for j in range(get_parent().height):
			var tile_bg = TileBGSprite.instance()
			tile_bg.position.x = i * Global.TILE_WIDTH
			tile_bg.position.y = j * Global.TILE_HEIGHT
			tile_bg.modulate = black
			add_child(tile_bg)
			tile_bgs[i].append(tile_bg)
	
	observer = get_parent().get_node("Player")
	for i in range(get_parent().width):
		for j in range(get_parent().height):
			var tile = get_parent().tile(i,j)
			tile.ground.render_sprite.modulate = black
			if tile.actor:
				tile.actor.get_node("Sprite").modulate = black
			if tile.obstacle && !tile.obstacle.seen_before:
				tile.obstacle.get_node("Sprite").modulate = black


func apply_vision(vision):
	var old_visible_tiles = vision.old_visible_tiles
	var visible_tiles = vision.visible_tiles
	for i in old_visible_tiles:
		var tile = get_parent().tilev(i)
		apply_tile_bg_tween(tile_bgs[i.x][i.y], black)
		tile.ground.apply_color_tween(black)
		if tile.actor:
			tile.actor.apply_color_tween(black)
		if tile.obstacle:
			tile.obstacle.apply_color_tween(grey)
	for i in visible_tiles:
		var tile = get_parent().tilev(i)
		light_tile(tile,i)
		var bg_color = light_levels_bg[tile.light_level]
		var fg_color = light_levels_fg[tile.light_level]
		if tile_bgs[i.x][i.y].modulate != bg_color:
			apply_tile_bg_tween(tile_bgs[i.x][i.y],bg_color)
		if tile.ground.render_sprite.modulate != fg_color:
			tile.ground.apply_color_tween(fg_color)
		if tile.actor && tile.actor.get_node("Sprite").modulate != fg_color:
			tile.actor.apply_color_tween(fg_color)
		if tile.obstacle && tile.obstacle.get_node("Sprite").modulate != fg_color:
			tile.obstacle.apply_color_tween(fg_color)
			tile.obstacle.seen_before = true


func apply_light(light):
	var old_visible_tiles = light.old_visible_tiles
	var visible_tiles = light.visible_tiles
	for i in old_visible_tiles:
		var tile = get_parent().tilev(i)
		if (light.old_source):
			tile.lit_by.erase(light.old_source)
	for i in visible_tiles:
		var tile = get_parent().tilev(i)
		if (light.old_source):
			tile.lit_by.erase(light.old_source)
		tile.lit_by[light.source] = {
			"light_level": visible_tiles[i].light_level,
			"faces": visible_tiles[i].faces
		}

func light_tile(tile,location):
	tile.light_level = 0
	if !tile.obstacle:
		for i in tile.lit_by:
			tile.light_level += tile.lit_by[i].light_level
	else:
		for i in tile.lit_by:
			var vision_faces = observer.get_node("Vision").visible_tiles[location]
			var light_faces = tile.lit_by[i].faces
			if ((vision_faces[0] && light_faces[0])
			 || (vision_faces[1] && light_faces[1])
			 || (vision_faces[2] && light_faces[2])
			 || (vision_faces[3] && light_faces[3])):
				tile.light_level += tile.lit_by[i].light_level
	tile.light_level = min(tile.light_level,6)


func apply_tile_bg_tween(sprite,target):
	$TileBGTween.interpolate_property(
		sprite, "modulate", sprite.modulate, target, 0.0833, Tween.TRANS_LINEAR
	)
	$TileBGTween.start()

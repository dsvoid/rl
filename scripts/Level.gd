extends Node

var Obstacle = preload("res://scenes/Obstacle.tscn")
var Player = preload("res://scenes/Player.tscn")
var Item = preload("res://scenes/Item.tscn")
var Ground = preload("res://scenes/Ground.tscn")
#var Torch = preload("res://scenes/Torch.tscn")
export var width = 40
export var height = 30
var tiles = []
var tileset = []
var tileset_columns
var lights = {}


func _init():
	for i in range(width):
		tiles.append([])
		for j in range(height):
			tiles[i].append(Tile.new())


func _ready():
	load_tileset("res://assets/12x12_test.json")
	load_level("res://maps/12x12_map.json")

	for emitter in lights.values():
		var light = emitter.get_node("RogueLight")
		light.compute_fov()
		$Renderer.apply_light(light.old_visible_tiles, light.visible_tiles)
	$Renderer.init_vision()
	$Player/Vision.compute_fov()
	$Renderer.apply_vision($Player/Vision.old_visible_tiles, $Player/Vision.visible_tiles)


func load_level(map_path):
	var f = File.new()
	f.open("%s" % map_path, f.READ)
	var map = JSON.parse(f.get_as_text()).result
	f.close()
	var map_width = int(map["width"])
	var map_tiles = map["layers"][0]["data"] # TODO: layer support, flooring
	for i in range(map_tiles.size()):
		var x = i % map_width
		var y = i / map_width
		var location = Vector2(x,y)
		var position = Vector2(x*Global.TILE_WIDTH, y*Global.TILE_HEIGHT)
		var ground = Ground.instance()
		tiles[x][y].ground = ground
		ground.tile = location
		ground.position = position
		add_child(ground)
		if map_tiles[i] != 0:
			var index = int(map_tiles[i]-1)
			var tile = tileset[index]
			var entity
			if tile.type == "obstacle":
				entity = Obstacle.instance()
				tiles[x][y].obstacle = entity
				entity.blocks_movement = tile.blocks_movement
				entity.blocks_vision = tile.blocks_vision
				add_child(entity)
			if tile.type == "actor":
				entity = Player.instance()
				tiles[x][y].actor = entity
				add_child(entity)
			if tile.type == "item":
				entity = Item.instance()
				# let ground handle representation of item
				entity.get_node("Sprite").visible = false
				tiles[x][y].ground.add_item(entity)
				add_child(entity)
			if tile.type == "ground":
				entity = ground
			entity.emits_light = tile.emits_light
			entity.tile = location
			entity.position = position
			if entity.emits_light:
				entity.set_light()
				lights[location] = entity
			var offset_x = (index % tileset_columns) * Global.TILE_WIDTH
			var offset_y = (index / tileset_columns) * Global.TILE_HEIGHT
			entity.get_node("Sprite").region_rect = Rect2(
				offset_x,
				offset_y,
				Global.TILE_WIDTH,
				Global.TILE_HEIGHT
			)


func load_tileset(tileset_path):
	var f = File.new()
	f.open("%s" % tileset_path, f.READ)
	var tiled_data = JSON.parse(f.get_as_text()).result
	f.close()
	var image_width = tiled_data["imagewidth"]
	var image_height = tiled_data["imageheight"]
	tileset_columns = int(tiled_data["columns"])
	for i in range(tiled_data["tiles"].size()):
		var tile = tiled_data["tiles"][i]
		var data = {}
		for j in range(tile["properties"].size()):
			var key = tile["properties"][j]["name"]
			var value = tile["properties"][j]["value"]
			data[key] = value
		tileset.append(data)


func tile(x,y):
	if in_bounds(x,y):
		return tiles[x][y]
	return false


func tilev(vector):
	if in_boundsv(vector):
		return tiles[vector.x][vector.y]
	return false


func in_bounds(x,y):
	return x > -1 && y > -1 && x < width && y < height


func in_boundsv(vector):
	return vector.x > -1 && vector.y > -1 && vector.x < width && vector.y < height


class Tile:
	var lights = {}
	var light_level = 0
	var obstacle = false
	var actor = false
	var ground = false

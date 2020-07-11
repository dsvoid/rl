extends Node

var Obstacle = preload("res://scenes/Obstacle.tscn")
var Player = preload("res://scenes/Player.tscn")
var Actor = preload("res://scenes/Actor.tscn")
var Item = preload("res://scenes/Item.tscn")
var Ground = preload("res://scenes/Ground.tscn")
var p # stores player node
var width
var height
var tiles = []
var tileset = []
var tileset_columns
var lights = []
var new_light_id = 0
var items = {}
var equip_arms = {}

func _ready():
	Global.level = self
	load_tileset("res://assets/12x12_dev.json")
	load_level("res://maps/0.2.0_map.json")

	for i in range(lights.size()):
		var emitter = lights[i]
		var light = emitter.get_node("RogueLight")
		light.compute_fov()
		$Renderer.apply_light(light)
	$Renderer.init_vision()
	p.get_node("Vision").compute_fov()
	$Renderer.apply_vision(p.get_node("Vision"))


func load_level(map_path):
	var f = File.new()
	f.open("%s" % map_path, f.READ)
	
	var map = JSON.parse(f.get_as_text()).result
	f.close()
	width = int(map["width"])
	height = int(map["height"])
	for i in range(width):
		tiles.append([])
		for j in range(height):
			tiles[i].append(Tile.new())
	var map_tiles = map["layers"][0]["data"] # TODO: layer support, flooring
	for i in range(map_tiles.size()):
		var x = i % width
		var y = i / width
		var location = Vector2(x,y)
		var position = Vector2(x*Global.TILE_WIDTH, y*Global.TILE_HEIGHT)
		var ground = Ground.instance()
		tiles[x][y].ground = ground
		ground.position = position
		ground.tile = location
		ground.usable_inventory = true
		add_child(ground)
		if map_tiles[i] != 0:
			var index = int(map_tiles[i]-1)
			var tile = tileset[index]
			var offset_x = (index % tileset_columns) * Global.TILE_WIDTH
			var offset_y = (index / tileset_columns) * Global.TILE_HEIGHT
			var sprite_rect = Rect2(
				offset_x, offset_y, Global.TILE_WIDTH, Global.TILE_HEIGHT
			)
			if tile.type == "ground":
				ground.ground_rect = sprite_rect
				ground.render_sprite.region_rect = ground.ground_rect
			if tile.type == "obstacle":
				add_obstacle(location,tile,sprite_rect)
			if tile.type == "actor":
				add_actor(location,tile,sprite_rect)
			if tile.type == "item":
				add_item(location,tile,index)
	$Renderer.init_mouse_highlight() #TODO: move somewhere nicer

func load_tileset(tileset_path):
	var f = File.new()
	f.open("%s" % tileset_path, f.READ)
	var tiled_data = JSON.parse(f.get_as_text()).result
	f.close()
	tileset_columns = int(tiled_data["columns"])
	for i in range(tiled_data["tiles"].size()):
		var tile = tiled_data["tiles"][i]
		var data = {}
		for j in range(tile["properties"].size()):
			var key = tile["properties"][j]["name"]
			var value = tile["properties"][j]["value"]
			data[key] = value
		tileset.append(data)
		if data.type == "equip_arms":
			register_equip_arm(i,data.title)


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


func add_obstacle(location,tile,sprite_rect):
	var position = Vector2(
		location.x*Global.TILE_WIDTH,
		location.y*Global.TILE_HEIGHT
	)
	var obstacle = Obstacle.instance()
	tiles[location.x][location.y].obstacle = obstacle
	obstacle.blocks_light = tile.blocks_light
	obstacle.blocks_vision = tile.blocks_vision
	obstacle.emits_light = tile.emits_light
	obstacle.usable_inventory = tile.usable_inventory
	obstacle.tile = location
	obstacle.position = position
	obstacle.title = tile.title
	obstacle.vaultable = tile.vaultable
	obstacle.get_node("Sprite").region_rect = sprite_rect
	add_child(obstacle)
	if obstacle.emits_light:
		obstacle.set_light()
		lights.append(obstacle)


func add_actor(location,tile,sprite_rect):
	var position = Vector2(
		location.x*Global.TILE_WIDTH,
		location.y*Global.TILE_HEIGHT
	)
	var actor
	if tile.title == "player":
		actor = Player.instance()
		p = actor
	else:
		actor = Actor.instance()
	tiles[location.x][location.y].actor = actor
	actor.emits_light = tile.emits_light
	actor.humanoid = tile.humanoid # TODO: make this a subclass of actor
	actor.one_handed = tile.one_handed
	actor.position = position
	actor.tile = location
	actor.title = tile.title
	actor.wide = tile.wide
	actor.get_node("Sprite").region_rect = sprite_rect
	add_child(actor)
	if actor.emits_light:
		actor.set_light()
		lights.append(actor)


# function assumes all placed items have distinct names
func add_item(location,tile,index):
	# add item to list if it doesn't exist yet
	if !items.has(tile.title):
		var item = Item.instance()
		item.category = tile.category
		item.emits_light = tile.emits_light
		item.sprite_index = index
		item.title = tile.title
		items[tile.title] = item
	tiles[location.x][location.y].ground.add_item(tile.title)


# function adds list of callable equippable arms
func register_equip_arm(index,title):
	var offset_x = (index % tileset_columns) * Global.TILE_WIDTH
	var offset_y = (index / tileset_columns) * Global.TILE_HEIGHT
	equip_arms[title] = Rect2(offset_x,offset_y,Global.TILE_WIDTH,Global.TILE_HEIGHT)


class Tile:
	var lit_by = {}
	var light_level = 0
	var obstacle = false
	var actor = false
	var ground = false

extends Node

export (PackedScene) var Obstacle
export (PackedScene) var Torch
export var width = 64
export var height = 30
var tiles = []


func _init():
	for i in range(width):
		tiles.append([])
		for j in range(height):
			tiles[i].append(Tile.new())


func _ready():
	var f = File.new()
	f.open("res://maps/test_map.json", f.READ)
	var map = JSON.parse(f.get_as_text()).result
	f.close()
	var map_tiles = map["layers"][0]["data"]
	for i in range(map_tiles.size()):
		if map_tiles[i] != 0:
			var x = i%width
			var y = i/width
			var obs = Obstacle.instance()
			add_child(obs)
			obs.position.x = x * get_node("/root/Global").TILE_WIDTH
			obs.position.y = y * get_node("/root/Global").TILE_HEIGHT
			tiles[x][y].obstacle = obs
	$VisionRenderer.init_vision()
#	var torch = Torch.instance()
#	add_child(torch)
#	torch.position.x = 160
#	torch.position.y = 228
#	torch.tile = Vector2(16,19)
#	tile(16,19).items.append(torch)
#	torch.get_node("RogueLight").compute_fov()
#	$VisionRenderer.apply_light(torch.get_node("RogueLight").old_visible_tiles, torch.get_node("RogueLight").visible_tiles)
	
	for i in range(50):
		var rand_tile = Vector2(randi()%width, randi()%height)
		while tilev(rand_tile).items.size() != 0 || tilev(rand_tile).obstacle:
			rand_tile = Vector2(randi()%width, randi()%height)
		var torch = Torch.instance()
		add_child(torch)
		torch.position.x = rand_tile.x * get_node("/root/Global").TILE_WIDTH
		torch.position.y = rand_tile.y * get_node("/root/Global").TILE_HEIGHT
		torch.tile = rand_tile
		tilev(rand_tile).items.append(torch)
		torch.get_node("RogueLight").compute_fov()
		$VisionRenderer.apply_light(torch.get_node("RogueLight").old_visible_tiles, torch.get_node("RogueLight").visible_tiles)
	$Player/Vision.compute_fov()
	$VisionRenderer.apply_vision($Player/Vision.old_visible_tiles, $Player/Vision.visible_tiles)


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
	var items = []
	var render_item = 0

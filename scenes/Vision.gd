extends Node
class_name Vision


var visible_tiles = {}
var old_visible_tiles
var view_shafts = []
var radius
var current_octant
var source


func _init(r=20):
	radius = r


func compute_fov():
	old_visible_tiles = visible_tiles.duplicate(true)
	current_octant = 0
	visible_tiles.clear()
	view_shafts.clear() # necessary?
	source = get_parent().tile
	add_tile(source)
	while current_octant < 8:
		var initial_view_shaft = ViewShaft.new(1,Vector2(1,0),Vector2(1,1))
		view_shafts.append(initial_view_shaft)
		while view_shafts.size() > 0 && view_shafts[0].column_x < radius:
			var current_view_shaft = view_shafts[0]
			view_shafts.pop_front()
			compute_shaft(current_view_shaft)
		view_shafts.clear()
		current_octant += 1


func compute_shaft(view_shaft):
	var column_x = view_shaft.column_x
	var bottom_vector = view_shaft.bottom_vector
	var top_vector = view_shaft.top_vector
	var adjusted_shaft = ViewShaft.new(column_x+1,bottom_vector,top_vector)
	# all tiles within this range are visible to the view shaft
	var bottom_visible_y = ceil(column_x*bottom_vector.y/bottom_vector.x)
	var top_visible_y = floor(column_x*top_vector.y/top_vector.x)
	# a "stippled" shaft might have no visible tiles for a column,
	# but will still need to do visibility checks on surfaces it crosses,
	# so tiles in this range are tested for blocking visibility.
	var bottom_shaft_y = floor(column_x*bottom_vector.y/bottom_vector.x)
	var top_shaft_y = ceil(column_x*top_vector.y/top_vector.x)
	
	top_visible_y = min(top_visible_y,floor(sqrt(radius*radius - column_x*column_x)))
	for i in range(top_shaft_y,bottom_shaft_y-1,-1):
		var relative_tile = Vector2(column_x,i)
		var actual_tile = get_actual_tile(relative_tile)
		if !get_parent().get_parent().in_boundsv(actual_tile):
			continue
		var added_tile = false
		if i <= top_visible_y && i >= bottom_visible_y:
			add_tile(actual_tile)
			if has_obstacle(Vector2(column_x,i)):
				set_seen_faces(actual_tile)
		if has_vision_blocker(Vector2(column_x,i)):
			var obstacle_above = has_vision_blocker(Vector2(column_x,i+1))
			if i != top_visible_y && !obstacle_above:
				var new_shaft = ViewShaft.new(column_x+1,Vector2(column_x*2,2*i+1),adjusted_shaft.top_vector)
				view_shafts.append(new_shaft)
			var obstacle_right = has_obstacle(Vector2(column_x+1,i))
			if i == bottom_visible_y:
				adjusted_shaft.top_vector = adjusted_shaft.bottom_vector
			elif obstacle_right:
				adjusted_shaft.top_vector = Vector2(2*column_x+1,2*i)
			else:
				adjusted_shaft.top_vector = Vector2(2*column_x,2*i-1)
	
	if adjusted_shaft.top_vector.y/float(adjusted_shaft.top_vector.x) > bottom_vector.y/float(bottom_vector.x):
		view_shafts.append(adjusted_shaft)


func get_actual_tile(relative_tile):
	var target = Vector2()
	target.x = get_parent().tile.x
	target.y = get_parent().tile.y
	if current_octant < 4:
		if current_octant % 4 < 2:
			target.x += relative_tile.x
		else:
			target.x -= relative_tile.x
		if current_octant % 2 == 0:
			target.y += relative_tile.y
		else:
			target.y -= relative_tile.y
	else:
		if current_octant % 4 < 2:
			target.x += relative_tile.y
		else:
			target.x -= relative_tile.y
		if current_octant % 2 == 0:
			target.y += relative_tile.x
		else:
			target.y -= relative_tile.x
	return target


func has_vision_blocker(relative_tile):
	var tile = get_parent().get_parent().tilev(get_actual_tile(relative_tile))
	if tile && tile.obstacle && tile.obstacle.blocks_vision:
		return true
	return false


func has_obstacle(relative_tile):
	var tile = get_parent().get_parent().tilev(get_actual_tile(relative_tile))
	if tile && tile.obstacle:
		return true
	return false


func has_vision_blocker_actual(actual_tile):
	var tile = get_parent().get_parent().tilev(actual_tile)
	if tile && tile.obstacle && tile.obstacle.blocks_vision:
		return true
	return false


func has_obstacle_actual(actual_tile):
	var tile = get_parent().get_parent().tilev(actual_tile)
	if tile && tile.obstacle:
		return true
	return false


func add_tile(tile):
	if !visible_tiles.has(tile):
		visible_tiles[tile] = [false,false,false,false] # up, down, left, right face


func set_seen_faces(tile):
	if (visible_tiles[tile][0] || 
		visible_tiles[tile][1] || 
		visible_tiles[tile][2] || 
		visible_tiles[tile][3]):
		return
	var v = Vector2(source.x-tile.x,source.y-tile.y)
	if v.y < 0 && !has_vision_blocker_actual(Vector2(tile.x,tile.y-1)):
		visible_tiles[tile][0] = true
	if v.y > 0 && !has_vision_blocker_actual(Vector2(tile.x,tile.y+1)):
		visible_tiles[tile][1] = true
	if v.x < 0 && !has_vision_blocker_actual(Vector2(tile.x-1,tile.y)):
		visible_tiles[tile][2] = true
	if v.x > 0 && !has_vision_blocker_actual(Vector2(tile.x+1,tile.y)):
		visible_tiles[tile][3] = true

class ViewShaft:
	var column_x
	var bottom_vector
	var top_vector
	
	func _init(col_x, bot_v, top_v):
		column_x = col_x
		bottom_vector = bot_v
		top_vector = top_v

extends Node
class_name RogueLight


var visible_tiles = []
var old_visible_tiles
var view_shafts = []
var radius
var current_octant


func _ready():
	radius = 20


func compute_fov():
	old_visible_tiles = visible_tiles.duplicate()
	current_octant = 0
	visible_tiles.clear()
	view_shafts.clear() # necessary?
	visible_tiles.append(get_parent().tile)
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
	
	var bottom_tile_y = ceil(column_x*bottom_vector.y/bottom_vector.x)
	var top_tile_y = floor(column_x*top_vector.y/top_vector.x)
	top_tile_y = min(top_tile_y,floor(sqrt(radius*radius - column_x*column_x)))
	
	for i in range(top_tile_y,bottom_tile_y-1,-1):
		var relative_tile = Vector2(column_x,i)
		var actual_tile = get_actual_tile(relative_tile)
		if (!get_parent().get_parent().in_boundsv(actual_tile)):
			continue
		visible_tiles.append(actual_tile)
		if has_vision_blocker(Vector2(column_x,i)):
			var obstacle_above = has_vision_blocker(Vector2(column_x,i+1))
			if i != top_tile_y && !obstacle_above:
				var new_shaft = ViewShaft.new(column_x+1,Vector2(column_x*2,2*i+1),adjusted_shaft.top_vector)
				view_shafts.append(new_shaft)
			var obstacle_right = has_vision_blocker(Vector2(column_x+1,i))
			# TODO: pray this works
			if i == bottom_tile_y:
				adjusted_shaft.top_vector = adjusted_shaft.bottom_vector #Vector2(2*column_x+1,2*i-1)
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
	

class ViewShaft:
	var column_x
	var bottom_vector
	var top_vector
	
	func _init(col_x, bot_v, top_v):
		column_x = col_x
		bottom_vector = bot_v
		top_vector = top_v

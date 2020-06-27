extends Entity
class_name Ground

# Grounds are entities because they need to be able to store items in their own
# inventory as a pile of stuff. They also have sprite representations.

# since the ground sprite might be updated a lot, this variable is its accessor
var render_sprite
# stores the original sprite position for the ground texture
var ground_rect = Rect2(0,0,0,0)


func _ready():
	render_sprite = $Sprite


func add_item(item):
	.add_item(item)
	# TODO: item prioritization on visibility.
	var sprite_index = item.sprite_index
	var tileset_columns = Global.level.tileset_columns
	var offset_x = (sprite_index % tileset_columns) * Global.TILE_WIDTH
	var offset_y = (sprite_index / tileset_columns) * Global.TILE_HEIGHT
	$Sprite.region_rect = Rect2(
		offset_x, offset_y, Global.TILE_WIDTH, Global.TILE_HEIGHT
	)


func remove_item(item):
	var i = .remove_item(item)
	if inventory_sorted_by_title.size() == 0:
		$Sprite.region_rect = ground_rect
	return i

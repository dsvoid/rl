extends Entity
class_name Actor

var sprite_index # used by ground when actor dies and corpse is generated
# reference to items in hands

###########
# ACTIONS #
###########

func move(direction):
	var target = Vector2(tile.x+direction.x, tile.y+direction.y)
	var old_tile = Global.level.tilev(tile)
	var new_tile = Global.level.tilev(target)
	# TODO: move rendering code elsewhere
	old_tile.ground.fade(1)
	new_tile.ground.fade(0)
	if old_tile.obstacle:
		old_tile.obstacle.fade(1)
	if new_tile.obstacle:
		new_tile.obstacle.fade(0)
	Global.level.tilev(tile).actor = false
	tile.x = target.x
	tile.y = target.y
	Global.level.tilev(tile).actor = self
	$Vision.compute_fov()
	if self == Global.level.p:
		Global.level.get_node("Renderer").apply_vision($Vision)
	var target_position = Vector2()
	target_position.x = position.x + Global.TILE_WIDTH * direction.x
	target_position.y = position.y + Global.TILE_HEIGHT * direction.y
	apply_motion_tween(target_position)
